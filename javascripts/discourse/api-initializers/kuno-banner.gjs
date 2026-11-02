import Component from "@glimmer/component";
import { service } from "@ember/service";
import { apiInitializer } from "discourse/lib/api";
import { defaultHomepage } from "discourse/lib/utilities";
import KunoBanner from "../components/kuno-banner";

// discovery-list-container-top sits inside #list-area, the box Horizon's topic cards
// live in, so the banner takes their width without hardcoding it.
// Same homepage test as core's welcome banner; the banner only mounts (and fetches)
// there.
class KunoBannerOutlet extends Component {
  @service router;

  get isHomepage() {
    return this.router.currentRouteName === `discovery.${defaultHomepage()}`;
  }

  <template>
    {{#if this.isHomepage}}
      <KunoBanner />
    {{/if}}
  </template>
}

export default apiInitializer((api) => {
  api.renderInOutlet("discovery-list-container-top", KunoBannerOutlet);
});
