class MetricsController < ApplicationController
  def index
    render plain: Prometheus::Client::Formats::Text.marshal(PROMETHEUS_REGISTRY),
           content_type: Prometheus::Client::Formats::Text::CONTENT_TYPE
  end
end