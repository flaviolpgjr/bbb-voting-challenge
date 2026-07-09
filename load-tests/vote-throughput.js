import http from "k6/http";
import { check } from "k6";

export const options = {
  scenarios: {
    votes_per_second: {
      executor: "constant-arrival-rate",
      rate: 1000,
      timeUnit: "1s",
      duration: "10s",
      preAllocatedVUs: 500,
      maxVUs: 1500,
    },
  },
  thresholds: {
    http_req_duration: ["p(95)<1000"],
  },
};

const BASE_URL = __ENV.BASE_URL || "http://localhost:3000";

export default function () {
  const participantId = Math.random() > 0.5 ? 1 : 2;

  const payload = JSON.stringify({
    participant_id: participantId,
    website: "",
    rendered_at: Date.now() - 3000,
  });

  const response = http.post(`${BASE_URL}/api/v1/votes`, payload, {
    headers: { "Content-Type": "application/json" },
  });

  check(response, {
    "vote accepted": (r) => r.status === 202,
  });
}
