class ScansHelper
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
