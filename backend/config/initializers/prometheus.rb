require "prometheus/client"
require "prometheus/client/formats/text"

PROMETHEUS_REGISTRY = Prometheus::Client.registry

VOTE_REQUESTS_COUNTER = PROMETHEUS_REGISTRY.counter(
  :vote_requests_total,
  docstring: "Total number of vote requests"
)

VOTES_ACCEPTED_COUNTER = PROMETHEUS_REGISTRY.counter(
  :votes_accepted_total,
  docstring: "Total number of accepted votes"
)

VOTES_REJECTED_COUNTER = PROMETHEUS_REGISTRY.counter(
  :votes_rejected_total,
  docstring: "Total number of rejected votes"
)