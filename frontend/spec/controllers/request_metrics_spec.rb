require "rails_helper"

# The METRICS line comes out of an around_action, which finishes long before the
# middleware that turns an exception into an error page. Reading response.status
# there reported a failed request as whatever the response happened to be
# holding, which is a 200 - so the one 500 in a night's traffic was invisible to
# anything reading these lines back.
RSpec.describe "RequestMetrics", type: :controller do
  controller(ApplicationController) do
    def ok
      render plain: "ok"
    end

    def timeout
      raise Timeout::Error, "execution expired"
    end

    def unknown_format
      raise ActionController::UnknownFormat
    end

    def timeout_while_measuring
      measure :search do
        metric :results, 7
        raise Timeout::Error, "execution expired"
      end
    end
  end

  before do
    routes.draw do
      %w[ok timeout unknown_format timeout_while_measuring].each do |action|
        get action => "anonymous##{action}"
      end
    end
    @log = StringIO.new
    @original_logger = ActionController::Base.logger
    ActionController::Base.logger = Logger.new(@log)
  end

  after do
    ActionController::Base.logger = @original_logger
  end

  # Same shape bin/analyze_rails_log parses back out of the log
  def metrics
    line = @log.string[/METRICS (.*)/, 1]
    raise "no METRICS line in #{@log.string.inspect}" unless line
    line.scan(/([\w.]+)=(?:"((?:[^"\\]|\\.)*)"|(\S*))/).to_h { |k, quoted, bare| [k, quoted || bare] }
  end

  it "reports the response status when the action succeeds" do
    get :ok
    expect(metrics["status"]).to eq("200")
    expect(metrics).not_to have_key("error")
    expect(metrics["endpoint"]).to eq("AnonymousController#ok")
  end

  it "reports 500 and the exception class when the action raises" do
    expect { get :timeout }.to raise_error(Timeout::Error)
    expect(metrics["status"]).to eq("500")
    expect(metrics["error"]).to eq("Timeout::Error")
  end

  # Not every failure is a 500, and the field is only useful if it says what the
  # client will actually be told
  it "reports the status the error page will get, not just 500" do
    expect { get :unknown_format }.to raise_error(ActionController::UnknownFormat)
    expect(metrics["status"]).to eq("406")
    expect(metrics["error"]).to eq("ActionController::UnknownFormat")
  end

  it "keeps stage timings and metrics recorded before the exception" do
    expect { get :timeout_while_measuring }.to raise_error(Timeout::Error)
    expect(metrics["error"]).to eq("Timeout::Error")
    expect(metrics["results"]).to eq("7")
    expect(metrics).to have_key("t.search")
  end
end
