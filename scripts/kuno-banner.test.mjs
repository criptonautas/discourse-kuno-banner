// node scripts/kuno-banner.test.mjs
import assert from "node:assert/strict";
import { pickForDay } from "../javascripts/discourse/lib/kuno-banner.js";

const topics = ["t1", "t2", "t3"];
const kunos = ["k1", "k2"];

// nothing at all -> no banner
assert.equal(pickForDay([], [], 7), null);

// both groups: internal on even days, external on odd ones, each at its own pace
const week = Array.from({ length: 8 }, (_, day) => pickForDay(topics, kunos, day));
assert.deepEqual(week, ["t1", "k1", "t2", "k2", "t3", "k1", "t1", "k2"]);

// a single topic and a single Kuno alternate exactly
assert.deepEqual(
  [0, 1, 2, 3].map((day) => pickForDay(["t"], ["k"], day)),
  ["t", "k", "t", "k"]
);

// an empty group hands every day to the other, one step per day
assert.deepEqual(
  [0, 1, 2, 3].map((day) => pickForDay([], kunos, day)),
  ["k1", "k2", "k1", "k2"]
);
assert.deepEqual(
  [0, 1, 2, 3].map((day) => pickForDay(topics, [], day)),
  ["t1", "t2", "t3", "t1"]
);

console.log("kuno-banner: ok");
