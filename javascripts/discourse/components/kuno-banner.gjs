import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { ajax } from "discourse/lib/ajax";
import { avatarUrl } from "discourse/lib/avatar-utils";
import getURL from "discourse/lib/get-url";
import { emojiUnescape } from "discourse/lib/text";
import { fancyTitle } from "discourse/lib/topic-fancy-title";
import Category from "discourse/models/category";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import { themePrefix } from "virtual:theme";
import {
  campaignProgress,
  formatXmr,
  parseOnebox,
  pickForDay,
  supportedKunos,
  today,
  topicIdFromUrl,
} from "../lib/kuno-banner";

const DISMISS_KEY = "kuno-banner-dismissed";

export default class KunoBanner extends Component {
  @service currentUser;
  @service keyValueStore;
  @service siteSettings;

  @tracked topics = [];
  @tracked dismissed = null;
  @tracked previews = {};
  @tracked avatar = null;

  day = today();

  constructor() {
    super(...arguments);
    this.dismissed = this.keyValueStore.get(DISMISS_KEY);
    this.loadTopics();
    this.loadAvatar();
  }

  // The banner speaks as system, like a post. No avatar if profiles are hidden.
  async loadAvatar() {
    try {
      const { user } = await ajax("/u/system/card.json");
      this.avatar = avatarUrl(user.avatar_template, "large");
    } catch {
      // Render without it.
    }
  }

  async loadTopics() {
    const tag = settings.kuno_tag?.trim();
    const categoryIds = (settings.kuno_categories || "")
      .split("|")
      .filter(Boolean)
      .map(Number);
    // Async: with lazy_load_categories the site may not have them loaded yet.
    const categories = await Category.asyncFindByIds(categoryIds).catch(() =>
      Category.findByIds(categoryIds)
    );
    const lists = await Promise.all([
      tag && this.fetchTopics(`/tag/${encodeURIComponent(tag)}.json`),
      ...categories.map((category) =>
        this.fetchTopics(`${category.path}/l/latest.json`)
      ),
    ]);
    // A category's own "About" topic is in its list but is not one to feature.
    const aboutTopics = categories.map((category) =>
      topicIdFromUrl(category.topic_url)
    );
    const byId = new Map();
    lists.flat().forEach((topic) => {
      if (topic && !aboutTopics.includes(topic.id)) {
        byId.set(topic.id, topic);
      }
    });
    // Sorted by id: the lists come bumped-first, which would reshuffle the pool (and
    // the day's pick) every time someone replies.
    const topics = [...byId.values()].sort((a, b) => a.id - b.id);
    // Loads the topics' own categories too, for the image fallback.
    await Category.asyncFindByIds(
      topics.map((topic) => topic.category_id).filter(Boolean)
    ).catch(() => {});
    this.topics = topics;
    this.loadOnebox();
  }

  async fetchTopics(url) {
    try {
      return (await ajax(url)).topic_list?.topics || [];
    } catch {
      // A missing tag or category 404s; the other sources still rotate.
      return [];
    }
  }

  // A Kuno's image, title and description come from Discourse's onebox of its page.
  // /onebox requires login, so visitors without a session get the URL only.
  async loadOnebox() {
    const url = this.item?.external && this.item.url;
    if (!url || !this.currentUser) {
      return;
    }
    try {
      const html = await ajax("/onebox", { dataType: "html", data: { url } });
      this.previews = { ...this.previews, [url]: parseOnebox(html) };
    } catch {
      // 404 (no preview) or 429 (another preview in flight): URL only.
    }
  }

  get item() {
    const topics = this.topics.map((topic) => ({
      key: `topic-${topic.id}`,
      // fancy_title and excerpt arrive HTML-escaped from the server with emoji as
      // :codes:; rendered as core renders them in topic lists.
      titleHtml: htmlSafe(
        fancyTitle(
          topic.fancy_title,
          this.siteSettings.support_mixed_text_direction
        )
      ),
      label: topic.title,
      url: getURL(`/t/${topic.slug}/${topic.id}`),
      // discourse-ai's gist when the viewer may see it, the excerpt otherwise.
      gist: topic.ai_topic_gist,
      excerptHtml:
        !topic.ai_topic_gist && topic.excerpt
          ? htmlSafe(emojiUnescape(topic.excerpt))
          : null,
      image: this.imageFor(topic),
      // Set by discourse-kuno-nautas on topics that carry a Monero campaign.
      campaign: topic.monero_campaign,
    }));
    const kunos = supportedKunos(settings.supported_kunos).map((url) => {
      const preview = this.previews[url];
      return {
        key: url,
        url,
        external: true,
        // Signed out there is no preview: the URL stands in for the description.
        excerpt: url,
        ...preview,
        label: preview?.title || url,
      };
    });
    const item = pickForDay(topics, kunos, this.day);
    return item && this.dismissed !== this.dismissKey(item) ? item : null;
  }

  // Like og:image, with the category's image before the site's: topic, category
  // background, category logo, site opengraph image.
  imageFor(topic) {
    const category = Category.findById(topic.category_id);
    return (
      topic.image_url ||
      category?.uploaded_background?.url ||
      category?.uploaded_logo?.url ||
      this.siteSettings.opengraph_image
    );
  }

  // Community Kunos draw their bar here; external ones only link out, since
  // Kuno's API has no lookup by fundraiser.
  get progress() {
    return campaignProgress(this.item?.campaign);
  }

  get progressStyle() {
    return htmlSafe(`width: ${this.progress?.width ?? 0}%;`);
  }

  get raisedText() {
    return formatXmr(this.item.campaign.raised);
  }

  get goalText() {
    return formatXmr(this.item.campaign.goal);
  }

  dismissKey(item) {
    return `${this.day}|${item.key}`;
  }

  @action
  dismiss() {
    this.dismissed = this.dismissKey(this.item);
    this.keyValueStore.set({ key: DISMISS_KEY, value: this.dismissed });
  }

  <template>
    {{#if this.item}}
      <div class="kuno-banner">
        {{! The featured image leads; system's avatar only stands in without one. }}
        {{#if this.item.image}}
          <div class="kuno-banner__image">
            <img src={{this.item.image}} alt="" />
          </div>
        {{else if this.avatar}}
          <img class="avatar kuno-banner__avatar" src={{this.avatar}} alt="" />
        {{/if}}

        <div class="kuno-banner__body">
          <p class="kuno-banner__title">
            {{i18n (themePrefix "kuno_banner.prefix")}}
            {{#if this.item.titleHtml}}
              {{this.item.titleHtml}}
            {{else if this.item.title}}
              {{this.item.title}}
            {{else}}
              {{i18n (themePrefix "kuno_banner.supporting")}}
            {{/if}}
          </p>
          {{#if this.item.gist}}
            <p class="kuno-banner__excerpt">{{this.item.gist}}</p>
          {{else if this.item.excerptHtml}}
            <p class="kuno-banner__excerpt">{{this.item.excerptHtml}}</p>
          {{else if this.item.excerpt}}
            <p class="kuno-banner__excerpt">{{this.item.excerpt}}</p>
          {{/if}}
          {{#if this.item.campaign}}
            <div class="kuno-banner__campaign">
              <span class="kuno-banner__figures">
                <strong>{{this.raisedText}}</strong>
                {{#if this.progress}}
                  <span>
                    {{i18n (themePrefix "kuno_banner.of_goal")}}
                    {{this.goalText}}
                    ·
                    {{this.progress.percentage}}%
                  </span>
                {{/if}}
              </span>
              {{#if this.progress}}
                <div
                  class="kuno-banner__track"
                  role="progressbar"
                  aria-valuemin="0"
                  aria-valuemax="100"
                  aria-valuenow={{this.progress.width}}
                  aria-label={{i18n (themePrefix "kuno_banner.progress_label")}}
                >
                  <span
                    class="kuno-banner__fill"
                    style={{this.progressStyle}}
                  ></span>
                </div>
              {{/if}}
            </div>
          {{/if}}
        </div>

        {{! One link over the whole card, like Horizon's topic cards; only the close
            button sits above it. }}
        <a
          class="kuno-banner__link"
          href={{this.item.url}}
          aria-label={{this.item.label}}
          target={{if this.item.external "_blank"}}
          rel={{if this.item.external "noopener noreferrer"}}
        ></a>

        <DButton
          class="btn-transparent kuno-banner__close"
          @icon="xmark"
          @action={{this.dismiss}}
          @title={{themePrefix "kuno_banner.dismiss"}}
        />
      </div>
    {{/if}}
  </template>
}
