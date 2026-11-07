# Kuno Banner — agent guide

Rules for anyone changing this repo, people and AI agents alike. Org-wide conventions
(README, licenses, commits) are in the
[contributing guide](https://github.com/criptonautas/.github/blob/main/CONTRIBUTING.md).

## Scope

A Discourse **theme component** for the Horizon theme. All work stays within:

```
javascripts/   ← api-initializer, the banner component, lib/ helpers
common/        ← common.scss
locales/       ← en.yml, es.yml (always both)
settings.yml   ← theme settings
test/          ← QUnit acceptance tests
spec/          ← core features system spec
```

## What it depends on

- **`discovery-list-container-top` outlet**: inside `#list-area`, the same box as
  Horizon's topic cards, so the banner takes their width. If it moves after a core
  update, check that outlet in `components/discovery/layout.gjs`.
- **`/onebox`** for supported Kunos: `requires_login` and one preview per user at a
  time, so signed-out visitors (and a 404/429) get the URL only. Its HTML is parsed
  with an inert `DOMParser` for the image, `h3` and first `p`; nothing from it is
  rendered as HTML, and there is no `htmlSafe` anywhere.
- **Homepage test** copied from core's welcome banner:
  `discovery.${defaultHomepage()}`.
- **`/tag/<tag>.json`** and **`/c/<id>/l/latest.json`**, read as the viewer. Topics
  in both are kept once; each category's About topic (`category.topic_id`) is dropped.
- **`/u/system/card.json`** for the avatar: fails when profiles are hidden from
  signed-out visitors (`hide_user_profiles_from_public`); the banner renders without it.
- **Horizon's high-context card chrome** (border, radius, title type, the phone layout)
  and the mod's hover and dark-scheme border are copied into `common.scss`; recheck
  them after a Horizon or mod update.

## UI

- **Air.** Every card or box keeps visible padding (`--space-4` at least,
  `--space-5`/`--space-6` on featured cards) and a gap between image and text. Spacing
  only with `--space-*` variables, never fixed pixels.
- Colours only from Discourse variables (`--primary-*`, `--secondary`, …), so light and
  dark schemes follow on their own.

## Gotchas

- The rotation pool must be stable through the day: topics are sorted by id, because the
  tag list comes bumped-first and would reshuffle on every reply.
- `supported_kunos` ends up in an `href`: keep the https-only filter in
  `lib/kuno-banner.js`.
- Topics that carry a `monero_campaign` (set by discourse-kuno-nautas) get a progress
  bar under the link; external Kunos only link out.
- Topic titles render with `{{}}` from `title`, not `fancy_title` (which is HTML-escaped
  and would show entities).
- Theme settings are read on each use, not at import, so tests can change them.

## Checks

```bash
pnpm install && pnpm lint
```

CI runs lint, the QUnit tests in `test/` and the core features spec. Lint and tests run
without Horizon, so also install the component on a Horizon site and look at the
homepage.
