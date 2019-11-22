class ChecksCreateEnqueueJob < ApplicationJob
  queue_as :default
  def perform(scan_id, scan_start_time, body, queue_now = false)
    params = ActionController::Parameters.new(JSON.parse(body))
    checks_params = params[:scan][:checks]
    Rails.logger.info "creating checks for scan_id #{scan_id}"
    checks_params.each do |check_params|
      whitelisted_check_params = check_params[:check].slice(:checktype_id, :checktype_name, :target, :options, :webhook, :jobqueue_id, :jobqueue_name, :tag, :required_vars => [])
      whitelisted_check_params.permit!
      check = ChecksHelper.create_check(whitelisted_check_params.to_h, scan_id)
      if check.nil?
        Rails.logger.error "error creating check with params: #{check_params[:check]} for scan_id #{scan_id}"
        next
      end
      # Queue_now is used only when invoqued from tests.
      if queue_now
        ChecksEnqueueJob.perform_now([check], scan_start_time)
      else
        ChecksEnqueueJob.perform_later([check], scan_start_time)
      end
    end
    rescue Exception => e
      Rails.logger.info ' error creating checks' + e.to_s
      raise e
    end
end
