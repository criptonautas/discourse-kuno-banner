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
import { themePrefix } from "virtual:theme";
import { pickForDay, supportedKunos, today } from "../lib/kuno-banner";

const DISMISS_KEY = "kuno-banner-dismissed";

export default class KunoBanner extends Component {
  @service currentUser;
  @service keyValueStore;

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
    if (tag) {
      try {
        const result = await ajax(`/tag/${encodeURIComponent(tag)}.json`);
        // Sorted by id: the list comes bumped-first, which would reshuffle the pool
        // (and the day's pick) every time someone replies.
        this.topics = (result.topic_list?.topics || []).sort(
          (a, b) => a.id - b.id
        );
      } catch {
        // A missing tag 404s; the supported Kunos still rotate on their own.
      }
    }
    this.loadOnebox();
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
      image: topic.image_url,
      category: Category.findById(topic.category_id)?.name,
    }));
    const kunos = supportedKunos(settings.supported_kunos).map((url) => ({
      key: url,
      url,
      external: true,
    }));
    const item = pickForDay([...topics, ...kunos], this.day);
    return item && this.dismissed !== this.dismissKey(item) ? item : null;
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
          {{else}}
            <aside class="onebox kuno-banner__onebox">
              {{#if this.item.category}}
                <header class="source">
                  <a href={{this.item.url}}>{{this.item.category}}</a>
                </header>
              {{/if}}
              <article class="onebox-body">
                {{#if this.item.image}}
                  <img class="thumbnail" src={{this.item.image}} alt="" />
                {{/if}}
                {{#if this.item.excerpt}}
                  <p>{{this.item.excerpt}}</p>
                {{/if}}
                <a class="kuno-banner__link" href={{this.item.url}}>
                  {{i18n (themePrefix "kuno_banner.read_topic")}}
                </a>
              </article>
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
