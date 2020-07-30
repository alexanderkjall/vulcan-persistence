require 'uuid'
class ScansHelper
  def self.get_metadata(scan)
    metadata = {
      "team" => "unknown-team",
      "program" => "unknown-program"
    }
    if scan.nil?
      Rails.logger.warn "error obtaining scan metadata for nil scan"
      return metadata
    end
    if scan[:program].blank?
      Rails.logger.warn "error obtaining program metadata for scan [#{scan.id}]"
    else
      metadata["program"] = scan[:program].downcase
    end
    if scan[:tag].blank?
      Rails.logger.warn "error obtaining team metadata for scan [#{scan.id}]"
    else
      metadata["team"] = scan[:tag].split(':').last.downcase
    end
    return metadata
  end

  def self.push_metric(scan,scanstatus="running")
    unless Rails.application.config.metrics
      return
    end
    metadata = self.get_metadata(scan)
    program_team = "#{metadata[:team]}-#{metadata[:program]}"
    metric_tags = ["scan:#{program_team}","scanstatus:#{scanstatus}"]
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
