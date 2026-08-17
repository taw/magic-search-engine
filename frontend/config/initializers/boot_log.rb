# Log one greppable line per process boot, so that a production log can be cut
# into "before the deploy" and "after the deploy" halves.
#
# Nothing else in the log says when the server was restarted - the deploy script
# only writes public/version.txt, which Rails never reads - so timings from two
# different versions of the code silently blend together in one log file.
#
#   BOOT pid=1234 env=production prog=puma version=cec5f1e9... deployed=2026-08-17T09:12:03Z
#     ruby=3.3.0 rails=5.1.7 root=/home/taw/magic-search-engine/frontend
#
# bin/analyze_rails_log reads these back (--since-last-boot).
module BootLog
  # Written by the deploy script as:
  #   Deployed on <iso8601> with version <sha>
  VERSION_FILE = Rails.root.join("public", "version.txt")

  def self.deploy_info
    text = File.read(VERSION_FILE) rescue nil
    return {} unless text
    m = /Deployed on (?<at>\S+) with version (?<sha>\S+)/.match(text)
    return {} unless m
    {"version" => m[:sha], "deployed" => m[:at]}
  end

  # In development there's no version.txt, but the checkout itself is the answer.
  def self.git_head
    head = File.read(Rails.root.join("..", ".git", "HEAD")).strip rescue nil
    return {} unless head
    sha =
      if head =~ /\Aref: (.*)/
        File.read(Rails.root.join("..", ".git", $1)).strip rescue nil
      else
        head
      end
    sha ? {"version" => sha} : {}
  end

  def self.fields
    {
      "pid" => Process.pid,
      "env" => Rails.env,
      "prog" => File.basename($PROGRAM_NAME),
    }.merge(deploy_info.empty? ? git_head : deploy_info).merge(
      "ruby" => RUBY_VERSION,
      "rails" => Rails.version,
      "root" => Rails.root.to_s,
    )
  end

  def self.line
    "BOOT " + fields.map { |k, v| "#{k}=#{v}" }.join(" ")
  end
end

Rails.application.config.after_initialize do
  Rails.logger.info BootLog.line
end
