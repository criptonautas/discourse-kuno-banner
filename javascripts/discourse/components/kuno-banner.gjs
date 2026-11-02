import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { avatarUrl } from "discourse/lib/avatar-utils";
import getURL from "discourse/lib/get-url";
import Category from "discourse/models/category";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import { themePrefix } from "virtual:theme";
import {
  htmlToText,
  parseOnebox,
  pickForDay,
  supportedKunos,
  today,
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
    const lists = await Promise.all([
      tag && this.fetchTopics(`/tag/${encodeURIComponent(tag)}.json`),
      ...categoryIds.map((id) => this.fetchTopics(`/c/${id}/l/latest.json`)),
    ]);
    // A category's own "About" topic is in its list but is not one to feature.
    const aboutTopics = categoryIds.map(
      (id) => Category.findById(id)?.topic_id
    );
    const byId = new Map();
    lists.flat().forEach((topic) => {
      if (topic && !aboutTopics.includes(topic.id)) {
        byId.set(topic.id, topic);
      }
    });
    // Sorted by id: the lists come bumped-first, which would reshuffle the pool (and
    // the day's pick) every time someone replies.
    this.topics = [...byId.values()].sort((a, b) => a.id - b.id);
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
      title: topic.title,
      url: getURL(`/t/${topic.slug}/${topic.id}`),
      // Arrives HTML-escaped (entities, &hellip;); decoded to plain text.
      excerpt: htmlToText(topic.excerpt),
      image: this.imageFor(topic),
    }));
    const kunos = supportedKunos(settings.supported_kunos).map((url) => ({
      key: url,
      url,
      external: true,
      // Signed out there is no preview: the URL stands in for the description.
      excerpt: url,
      ...this.previews[url],
    }));
    const item = pickForDay([...topics, ...kunos], this.day);
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
          <img class="kuno-banner__image" src={{this.item.image}} alt="" />
        {{else if this.avatar}}
          <img class="avatar kuno-banner__avatar" src={{this.avatar}} alt="" />
        {{/if}}

        <div class="kuno-banner__body">
          <p class="kuno-banner__title">
            {{i18n (themePrefix "kuno_banner.prefix")}}
            {{#if this.item.title}}
              {{this.item.title}}
            {{else}}
              {{i18n (themePrefix "kuno_banner.supporting")}}
            {{/if}}
          </p>
          {{#if this.item.excerpt}}
            <p class="kuno-banner__excerpt">{{this.item.excerpt}}</p>
          {{/if}}
        </div>

        {{! One link over the whole card, like Horizon's topic cards; only the close
            button sits above it. }}
        <a
          class="kuno-banner__link"
          href={{this.item.url}}
          aria-label={{if this.item.title this.item.title this.item.url}}
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
