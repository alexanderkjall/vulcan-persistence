require 'uuid'
class ScansHelper
  def self.push_metric(scan,scanstatus="running")
    unless Rails.application.config.metrics
      return
    end
    scan_label = "unknown-program"
    team_label = "unknown-team"
    if scan[:program].blank?
      Rails.logger.warn "error obtaining program name for scan [#{scan.id}] for pushing metrics"
    else
      scan_label = scan[:program].downcase
    end
    if scan[:tag].blank?
      Rails.logger.warn "error obtaining team name for scan [#{scan.id}] for pushing metrics"
    else
      team_label = scan[:tag].split(':').last.downcase
    end

    metric_tags = ["scan:#{team_label}-#{scan_label}","scanstatus:#{scanstatus}"]
    Metrics.count("scan.count", 1, metric_tags)
  end

  def self.normalize_program(program_id)
    if program_id.blank?
      return "unknown-program"
    end
    if UUID.validate(program_id)
      return "custom-program"
    end
    if program_id.include? "@"
      return program_id.split("@").last.downcase
    end
    return program_id.downcase
  end

  def self.is_aborted(scan_id)
    if scan_id
      scan = Scan.find(scan_id)
      unless scan.nil?
        return scan.aborted
      end
    end
    return false
  end
end
