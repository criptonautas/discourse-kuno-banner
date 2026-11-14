export function today() {
  return Math.floor(Date.now() / 86_400_000);
}

// Same item for everyone on a given UTC day. Even days an internal item, odd days an
// external one, each group stepping at its own pace; an empty group hands every day
// to the other.
export function pickForDay(internal, external, day) {
  if (!internal.length || !external.length) {
    const pool = internal.length ? internal : external;
    return pool.length ? pool[day % pool.length] : null;
  }

  const pool = day % 2 === 0 ? internal : external;
  return pool[Math.floor(day / 2) % pool.length];
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

// Client categories carry no topic_id, only topic_url ("/t/<slug>/<id>").
export function topicIdFromUrl(url) {
  const id = url?.match(/\/(\d+)\/?$/)?.[1];
  return id ? Number(id) : null;
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
