# Emits one greppable line per request with the things Rails' own "Completed"
# line leaves out: who the client claims to be, and where the time actually went
# inside the action.
#
# Without the user agent it's impossible to tell a crawler walking page 1300 of
# a search from a real visitor, and without per-stage timings a slow search page
# is just one number with no clue which part of it was slow.
#
#   METRICS ms=12345 status=200 endpoint=CardController#index page=1319 \
#     t.search=11800 results=35657 \
#     ip=1.2.3.4 ua="Mozilla/5.0 (compatible; Whatever/1.0)" path="/page/1319/card?q=in%3Apaper"
#
# A request that raised gets the status the error page will end up with, plus
# the exception class, so failures are findable by `grep error= production.log`:
#
#   METRICS ms=5247 status=500 error=Timeout::Error endpoint=CardController#index ...
#
# bin/analyze_rails_log reads these back.
module RequestMetrics
  extend ActiveSupport::Concern

  # Requests at least this slow also get a separate SLOW line, so that
  # `grep SLOW production.log` is enough to find the bad ones.
  SLOW_REQUEST_MS = Integer(ENV.fetch("MTG_WTF_SLOW_REQUEST_MS", 1000))

  included do
    around_action :record_request_metrics
  end

  # Time a stage of the action and record it as t.<name> on the metrics line.
  def measure(name)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
  ensure
    @request_metrics ||= {}
    @request_metrics["t.#{name}"] =
      ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
  end

  # Record an arbitrary field on the metrics line.
  def metric(name, value)
    @request_metrics ||= {}
    @request_metrics[name.to_s] = value
  end

  private

  def record_request_metrics
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
  rescue Exception => e
    # The middleware that turns this into an error page runs long after we're
    # gone, so this is the only chance to see that the request failed at all.
    error = e
    raise
  ensure
    begin
      ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
      fields = {
        "ms" => ms,
        "status" => error ? status_for_exception(error) : response&.status,
      }
      fields["error"] = error.class.name if error
      fields["endpoint"] = "#{self.class.name}##{action_name}"
      fields.merge!(@request_metrics || {})
      fields["ip"] = request.remote_ip
      fields["ua"] = quote(request.user_agent)
      fields["path"] = quote(request.fullpath)

      line = fields.map{|k, v| "#{k}=#{v}" }.join(" ")
      logger.info "METRICS #{line}"
      logger.warn "SLOW #{line}" if ms >= SLOW_REQUEST_MS
    rescue => e
      # Never let instrumentation break a response
      logger.error "RequestMetrics failed: #{e.class}: #{e.message}" rescue nil
    end
  end

  # What ActionDispatch::ShowExceptions will turn this exception into, by the
  # same table it uses. Not every failure is a 500: UnknownFormat is a 406,
  # ParameterMissing a 400. Template errors carry the real one as their cause.
  def status_for_exception(error)
    wrapper = ActionDispatch::ExceptionWrapper
    class_name = error.class.name
    if wrapper.wrapper_exceptions.include?(class_name) && error.cause
      class_name = error.cause.class.name
    end
    wrapper.status_code_for_exception(class_name)
  end

  def quote(value)
    %["#{value.to_s[0, 300].gsub('\\', '\\\\\\\\').gsub('"', '\\"').gsub(/[[:cntrl:]]/, " ")}"]
  end
end
