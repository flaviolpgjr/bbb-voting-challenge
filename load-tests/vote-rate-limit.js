import http from "k6/http";
import { check } from "k6";

export const options = {
  scenarios: {
    rate_limit_validation: {
      executor: "constant-arrival-rate",
      rate: 100,
      timeUnit: "1s",
      duration: "30s",
      preAllocatedVUs: 100,
      maxVUs: 300,
    },
  },
};

const BASE_URL = __ENV.BASE_URL || "http://localhost:3000";

export default function () {
  const payload = JSON.stringify({
    participant_id: 1,
    website: "",
    rendered_at: Date.now() - 3000,
  });

  const response = http.post(`${BASE_URL}/api/v1/votes`, payload, {
    headers: { "Content-Type": "application/json" },
  });

  check(response, {
    "rate limited or accepted": (r) => [202, 429].includes(r.status),
  });
}
