tracing_state = ENV.fetch('DATADOG_TRACING')

if tracing_state == "true"
  require 'ddtrace'

  Rails.configuration.datadog_trace = {
    auto_instrument: true,
    auto_instrument_redis: false,
    default_service: 'vulcan-persistence-app',
    trace_agent_port: 8126
  }
end
