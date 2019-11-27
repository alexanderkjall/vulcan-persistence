class JobQueuesHelper
  def self.get_queue_name(jobqueue_id = nil, jobqueue_name = nil, checktype = nil)
    nessus_check_queue = Rails.application.config.nessus_check_queue
    # returning queue_name by jobqueue_name specified in check
    unless jobqueue_name.nil?
      jobqueue = Jobqueue.where(deleted_at: nil, name: jobqueue_name).first
      if jobqueue.nil?
        Rails.logger.error "can't find queue with name #{jobqueue_name} specified in check"
        return nil
      end
      return jobqueue.name
    end
    # returning queue_name by jobqueue_id specified in check
    unless jobqueue_id.nil?
      jobqueue = Jobqueue.where(deleted_at: nil, id: jobqueue_id).first
      if jobqueue.nil?
        Rails.logger.error "can't find queue with id #{jobqueue_id} specified in check"
        return nil
      end
      return jobqueue.name
    end
    # returning queue_name by check's checktype
    unless checktype.nil?
      # default case is that checktype queue_name is nil
      # therefore we don't want to fail if queue_name is
      # not specified at checktype level
      unless checktype.queue_name.nil?
        return checktype.queue_name
      end
      # return nessus specific queue if defined in configuration
      # and not defined by checktype
      if checktype.name.start_with? "vulcan-nessus"
        return nessus_check_queue unless nessus_check_queue == "default"
      end
    end
    # returning default queue_name
    jobqueue = Jobqueue.where(deleted_at: nil, default: true).first
    if jobqueue.nil?
      Rails.logger.error "unable to find a proper jobqueue"
      return nil
    end
    return jobqueue.name
  end
end
