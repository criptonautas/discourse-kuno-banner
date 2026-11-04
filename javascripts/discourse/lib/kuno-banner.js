// Same item for everyone on a given UTC day; tomorrow moves one step through the pool.
export function today() {
  return Math.floor(Date.now() / 86_400_000);
}

export function pickForDay(items, day) {
  return items.length ? items[day % items.length] : null;
}

// The URLs come from an admin setting but still land in an href, so anything that
// isn't an absolute https URL (javascript:, typos, relative paths) is dropped.
export function supportedKunos(setting) {
  return (setting || "")
    .split("|")
    .map((value) => value.trim())
    .filter((value) => {
      try {
        return new URL(value).protocol === "https:";
      } catch {
        return false;
      }
    });
}

// Text only: DOMParser documents are inert (no scripts, no image loads), and the
// result is rendered escaped, so no HTML from the server reaches the page.
export function htmlToText(html) {
  return html
    ? new DOMParser().parseFromString(html, "text/html").body.textContent.trim()
    : null;
}

// The parts of a Discourse onebox the banner draws in its own layout.
export function parseOnebox(html) {
  const doc = new DOMParser().parseFromString(html, "text/html");
  const body = doc.querySelector(".onebox-body") || doc.body;
  const text = (selector) =>
    body.querySelector(selector)?.textContent.trim() || null;
  return {
    image: body.querySelector("img:not(.site-icon)")?.getAttribute("src"),
    title: text("h3"),
    excerpt: text("p"),
  };
}

export function formatXmr(amount) {
  const formatter = new Intl.NumberFormat(undefined, {
    maximumFractionDigits: 4,
  });
  return `${formatter.format(Number(amount) || 0)} XMR`;
}

// Percentage of the goal; width is capped so the bar (and aria-valuenow) never
// overflow while the figure may read over 100. No goal, no bar.
export function campaignProgress(campaign) {
  const goal = Number(campaign?.goal) || 0;
  if (goal <= 0) {
    return null;
  }
  const raw = ((Number(campaign.raised) || 0) / goal) * 100;
  return { percentage: Math.round(raw), width: Math.min(100, raw) };
}
