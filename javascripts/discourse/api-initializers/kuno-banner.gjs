import Component from "@glimmer/component";
import { service } from "@ember/service";
import { apiInitializer } from "discourse/lib/api";
import { defaultHomepage } from "discourse/lib/utilities";
import KunoBanner from "../components/kuno-banner";
import { listHomepage } from "../lib/kuno-banner";

// discovery-list-container-top sits inside #list-area, the box Horizon's topic cards
// live in, so the banner takes their width without hardcoding it. It shows on the
// homepage list, or on the first top menu list when the homepage is /custom.
class KunoBannerList extends Component {
  @service router;
  @service siteSettings;

  get show() {
    const list = listHomepage(defaultHomepage(), this.siteSettings.top_menu);
    return this.router.currentRouteName === `discovery.${list}`;
  }

  <template>
    {{#if this.show}}
      <KunoBanner />
    {{/if}}
  </template>
}

// /custom has no list. top-notices renders after main-outlet-blocks (Custom Home
// Nautas' hero) and before the page itself (its homepage-blocks), on every page.
class KunoBannerCustomHome extends Component {
  @service router;

  get show() {
    return this.router.currentRouteName === "discovery.custom";
  }

  <template>
    {{#if this.show}}
      <KunoBanner />
    {{/if}}
  </template>
}

export default apiInitializer((api) => {
  api.renderInOutlet("discovery-list-container-top", KunoBannerList);
  api.renderInOutlet("top-notices", KunoBannerCustomHome);
});
