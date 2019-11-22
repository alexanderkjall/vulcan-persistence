class ChecksHelper
  def self.create_check(params, scan_id = nil)
    if params[:checktype_name].present?
      if params[:checktype_id].present?
        Rails.logger.error "both checktype_name and checktype_id present in params: #{params.inspect}"
        return nil
      end

      checktype = Checktype.where(name: params[:checktype_name], enabled: true, deleted_at: nil).order('created_at DESC').first
      if checktype.nil?
        Rails.logger.error "checktype with name #{params[:checktype_name]} not found"
        return nil
      end

      params[:checktype_id] = checktype.id
      params.delete(:checktype_name)
    elsif params[:checktype_id].present?
      if params[:checktype_name].present?
        Rails.logger.error "both checktype_name and checktype_id present in params: #{params.inspect}"
        return nil
      end

      checktype = Checktype.where(id: params[:checktype_id], enabled: true, deleted_at: nil).order('created_at DESC').first
      if checktype.nil?
        Rails.logger.error "checktype with id #{params[:checktype_id]} not found"
        return nil
      end

      if checktype.deleted_at || !checktype.enabled
        Rails.logger.error "checktype with id #{params[:checktype_id]} not found"
        return nil
      end
    else
      Rails.logger.error "both checktype_name and checktype_id missing in params: #{params.inspect}"
      return nil
    end

    queue_name = JobQueuesHelper.get_queue_name(params[:jobqueue_id], params[:jobqueue_name], checktype)
    if queue_name.nil?
      Rails.logger.error "no queue found to enqueue check: #{params.inspect}"
      return nil
    end
    # jobqueue_id and jobqueue_name are no attributes of a check,
    # therefore need to be removed before creating the check
    params.delete('jobqueue_name')
    params.delete('jobqueue_id')

    # TODO: check what happens if params doesn't comply with the model.
    check = Check.new(params)

    # Sanitize and merge check options
    hash_param_options = Hash.new
    begin
      if params[:options].present?
        hash_param_options = JSON.parse(params[:options])
      end
    rescue
      Rails.logger.error "malformed check options #{params[:options]}"
      return nil
    end

    hash_checktype_options = Hash.new
    begin
      if checktype.options.present?
        hash_checktype_options = JSON.parse(checktype.options)
      end
    rescue
      Rails.logger.error "malformed checktype options #{checktype.options}"
      return nil
    end

    check.options = hash_checktype_options.deep_merge(hash_param_options).to_json

    check.required_vars = checktype.required_vars

    unless scan_id.nil?
      check.scan_id = scan_id
    end

    # queue_name can't be nil as is checked some lines above
    check.queue_name = queue_name

    unless check.save
      Rails.logger.error "error saving the check: #{check.inspect}"
      return nil
    end

    # NOTE: take into account that increasing the scan size for every created chheck,
    # is increasing the number of queries to database x3, as we are getting the scan
    # from the database and saving it again, for every created check.
    if check.scan_id
      begin
        scan = Scan.find(check.scan_id)
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error "scan with id #{check.scan_id} not found"
        return nil
      end
      unless scan.increment!(:size)
        Rails.logger.error "error incrementing the size of the scan #{scan.id}"
        return nil
      end
    end
    check
  end
end
