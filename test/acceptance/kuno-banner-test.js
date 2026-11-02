import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { cloneJSON } from "discourse/lib/object";
import discoveryFixtures from "discourse/tests/fixtures/discovery-fixtures";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

const KUNO = "https://kuno.anne.media/fundraiser/abcd";

// One item per test, so the day's pick is the same whatever the date.
const tagged = cloneJSON(discoveryFixtures["/latest.json"]);
tagged.topic_list.topics = tagged.topic_list.topics.slice(0, 1);
const [topic] = tagged.topic_list.topics;
// No topic image, so the card falls back like og:image (to the site setting below,
// assuming the fixture category has no images).
delete topic.image_url;

acceptance("Kuno Banner", function (needs) {
  let tagTopics;

  needs.settings({ opengraph_image: "/images/og.png" });

  needs.pretender((server, helper) => {
    server.get("/u/system/card.json", () =>
      helper.response({
        user: {
          avatar_template: "/letter_avatar_proxy/v4/letter/s/1/{size}.png",
        },
      })
    );
    server.get("/tag/kuno.json", () =>
      tagTopics ? helper.response(cloneJSON(tagged)) : helper.response(404, {})
    );
    server.get("/c/:id/l/latest.json", () =>
      helper.response(cloneJSON(tagged))
    );
  });

  let original, originalCategories;

  needs.hooks.beforeEach(function () {
    localStorage.clear();
    tagTopics = true;
    original = settings.supported_kunos;
    originalCategories = settings.kuno_categories;
    settings.supported_kunos = "";
    settings.kuno_categories = "";
  });

  needs.hooks.afterEach(function () {
    settings.supported_kunos = original;
    settings.kuno_categories = originalCategories;
  });

  test("shows a topic from kuno_categories", async function (assert) {
    tagTopics = false;
    settings.kuno_categories = String(topic.category_id);

    await visit("/");

    assert.dom(".kuno-banner__title a").hasText(topic.title);
  });

  test("shows the tagged topic on the homepage", async function (assert) {
    await visit("/");

    assert.dom(".kuno-banner__title").includesText("[KUNO]");
    assert.dom(".kuno-banner__title a").hasText(topic.title);
    assert
      .dom(".kuno-banner__title a")
      .hasAttribute("href", `/t/${topic.slug}/${topic.id}`);
    assert
      .dom(".kuno-banner__onebox h3")
      .doesNotExist("the title is already on top");
    assert.dom("aside.onebox.kuno-banner__onebox").exists();
    assert.dom(".kuno-banner__avatar").exists();
    assert
      .dom(".kuno-banner__onebox img.thumbnail")
      .hasAttribute("src", "/images/og.png", "falls back like og:image");
  });

  test("shows a supported Kuno when no topic has the tag", async function (assert) {
    tagTopics = false;
    settings.supported_kunos = KUNO;

    await visit("/");

    assert.dom(".kuno-banner__title").exists();
    assert.dom("aside.onebox.kuno-banner__onebox").exists();
    assert.dom(".kuno-banner__link").hasText(KUNO);
    assert.dom(".kuno-banner__link").hasAttribute("href", KUNO);
    assert.dom(".kuno-banner__link").hasAttribute("rel", "noopener noreferrer");
  });

  test("drops supported Kunos that aren't https", async function (assert) {
    tagTopics = false;
    settings.supported_kunos = "javascript:alert(1)|http://kuno.example";

    await visit("/");

    assert.dom(".kuno-banner").doesNotExist();
  });

  test("stays hidden after dismissing", async function (assert) {
    await visit("/");
    await click(".kuno-banner__close");

    assert.dom(".kuno-banner").doesNotExist();

    await visit("/top");
    await visit("/");

    assert.dom(".kuno-banner").doesNotExist();
  });

  test("only renders on the homepage", async function (assert) {
    await visit("/top");

    assert.dom(".kuno-banner").doesNotExist();
  });
});

acceptance("Kuno Banner | signed in", function (needs) {
  needs.user();

  needs.pretender((server, helper) => {
    server.get("/u/system/card.json", () => helper.response(404, {}));
    server.get("/tag/kuno.json", () => helper.response(404, {}));
    server.get("/onebox", () => [
      200,
      { "Content-Type": "text/html" },
      '<aside class="onebox" data-onebox-src="x">Kuno preview</aside>',
    ]);
  });

  let original;

  needs.hooks.beforeEach(function () {
    localStorage.clear();
    original = settings.supported_kunos;
    settings.supported_kunos = KUNO;
  });

  needs.hooks.afterEach(function () {
    settings.supported_kunos = original;
  });

  test("shows the real onebox for a supported Kuno", async function (assert) {
    await visit("/");

    assert.dom(".kuno-banner__onebox aside.onebox").hasText("Kuno preview");
  });
});
