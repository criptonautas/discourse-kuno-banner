# Kuno Banner

**ENGLISH** | [ESPAÑOL](README.es.md)

Maintained by Criptonautas. Not affiliated with or endorsed by Discourse (Civilized Discourse Construction Kit, Inc.).

A dismissable homepage banner that changes every day, showing either a forum topic (from a
chosen tag or category) or an external [Kuno](https://codeberg.org/nebras/kuno) Monero fundraiser
the community supports. Built for the
[Horizon](https://meta.discourse.org/t/horizon-theme/360486) theme.

## What it does

- **One pool, one item a day.** Topics with `kuno_tag` or in `kuno_categories` (oldest
  first, each once) followed by the `supported_kunos` URLs. Everyone sees the same item on the same UTC day; the next day
  moves one step and wraps around.
- **Laid out like a post:** the `system` avatar on the left, the text and a onebox
  on the right, in a card styled like Horizon's topic cards.
- **One title line for every item** (`kuno_banner.supporting`, editable in the
  component's translations), with a onebox below in core's onebox styles.
- **Topics:** a onebox with the topic's image, title and excerpt, built from the topic
  list, so everyone sees it. No topic image: the category's background, then its
  logo, then the site's opengraph image.
- **The whole card is clickable**, through the title's link.
- **Supported Kunos:** the real onebox (title, image and description from the Kuno page) for
  signed-in members, or a plain card with the link for everyone else. Links open in a
  new tab. Only `https://` URLs are kept.
- **Dismissable.** The close button hides the banner in that browser until the next
  day's item. Works for signed-out visitors too.
- **Homepage only**, above the topic list and as wide as Horizon's topic cards. Nothing renders when the pool is empty.

## Settings

| Setting | Default | |
|---|---|---|
| `kuno_tag` | `kuno` | Tag whose topics join the rotation. Empty to show only supported Kunos. |
| `kuno_categories` | empty | Categories whose topics join the rotation. Their About topic is left out. |
| `supported_kunos` | empty | External Kuno fundraiser URLs. |

The banner text lives in the component's translations (`kuno_banner.supporting`).

## Limits

- **Onebox needs a session.** Discourse's `/onebox` endpoint requires login, so
  signed-out visitors see the plain card.
- **No live Kuno data.** Kuno publishes no API or feed: fundraising progress never
  shows, and the plain card shows only the URL.
- **Private topics stay private.** Topics are read from the tag and category lists as the viewer,
  so visitors who can't see a topic don't get it in their rotation, and their day's
  pick can differ.

## Install

**Admin → Appearance → Themes & components → Install**, from this repository's URL, then
add it to Horizon.

## Development

`pnpm install && pnpm lint`. CI also runs the QUnit tests in `test/` and the core
features spec. Contributor notes are in [AGENTS.md](AGENTS.md).

## License

MIT. See [LICENSE](LICENSE).

Text of this README under [CC BY-NC-SA 4.0](CC-BY-NC-SA-4.0.txt).
