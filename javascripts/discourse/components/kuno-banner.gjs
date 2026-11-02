import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { ajax } from "discourse/lib/ajax";
import { avatarUrl } from "discourse/lib/avatar-utils";
import getURL from "discourse/lib/get-url";
import Category from "discourse/models/category";
import DButton from "discourse/ui-kit/d-button";
import { i18n } from "discourse-i18n";
import { or } from "truth-helpers";
import { themePrefix } from "virtual:theme";
import { pickForDay, supportedKunos, today } from "../lib/kuno-banner";

const DISMISS_KEY = "kuno-banner-dismissed";

export default class KunoBanner extends Component {
  @service currentUser;
  @service keyValueStore;
  @service siteSettings;

  @tracked topics = [];
  @tracked dismissed = null;
  @tracked oneboxes = {};
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

  // /onebox requires login, so visitors without a session keep the plain card.
  async loadOnebox() {
    const url = this.item?.external && this.item.url;
    if (!url || !this.currentUser) {
      return;
    }
    try {
      const html = await ajax("/onebox", { dataType: "html", data: { url } });
      // Oneboxer output, already sanitized server-side: the same HTML core puts in
      // posts.
      this.oneboxes = { ...this.oneboxes, [url]: htmlSafe(html) };
    } catch {
      // 404 (no preview) or 429 (another preview in flight): keep the plain card.
    }
  }

  get item() {
    const topics = this.topics.map((topic) => ({
      key: `topic-${topic.id}`,
      title: topic.title,
      url: getURL(`/t/${topic.slug}/${topic.id}`),
      // Escaped server-side; core renders it the same way (topic.escapedExcerpt).
      excerpt: topic.excerpt && htmlSafe(topic.excerpt),
      image: this.imageFor(topic),
    }));
    const kunos = supportedKunos(settings.supported_kunos).map((url) => ({
      key: url,
      url,
      external: true,
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

  get onebox() {
    return this.oneboxes[this.item?.url];
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
        {{#if this.avatar}}
          <img class="avatar kuno-banner__avatar" src={{this.avatar}} alt="" />
        {{/if}}
        <div class="kuno-banner__body">
          <p class="kuno-banner__title">
            {{i18n (themePrefix "kuno_banner.prefix")}}
            {{#if this.item.external}}
              {{i18n (themePrefix "kuno_banner.supporting")}}
            {{else}}
              <a href={{this.item.url}}>{{this.item.title}}</a>
            {{/if}}
          </p>

          {{! core's aside.onebox styles are global, so both cards look like post oneboxes }}
          {{#if this.onebox}}
            <div class="kuno-banner__onebox">{{this.onebox}}</div>
          {{else if this.item.external}}
            <aside class="onebox kuno-banner__onebox">
              <article class="onebox-body">
                <h3><a
                    class="kuno-banner__link"
                    href={{this.item.url}}
                    target="_blank"
                    rel="noopener noreferrer"
                  >{{this.item.url}}</a></h3>
              </article>
            </aside>
          {{else if (or this.item.image this.item.excerpt)}}
            <aside class="onebox kuno-banner__onebox">
              <article class="onebox-body">
                {{#if this.item.image}}
                  <img class="thumbnail" src={{this.item.image}} alt="" />
                {{/if}}
                {{#if this.item.excerpt}}
                  <p>{{this.item.excerpt}}</p>
                {{/if}}
              </article>
              {{! The title above is the real link; this only makes the card clickable. }}
              <a
                class="kuno-banner__link"
                href={{this.item.url}}
                tabindex="-1"
                aria-hidden="true"
              ></a>
            </aside>
          {{/if}}
        </div>

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
