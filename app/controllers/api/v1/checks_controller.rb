module Api::V1
  class ChecksController < ApplicationController
    before_action :set_check, only: [:show, :update, :destroy, :abort, :kill]

    # GET /checks
    def index
      if params[:force].to_s.downcase != "true"
        render :json => { :error => "List method is not allowed without force param"}, status: :method_not_allowed
        return
      end
      @checks = Check.where(deleted_at: nil).filter(params.slice(:status, :target, :checktype_id, :agent_id))

      render json: @checks
    end

    # GET /checks/1
    def show
      render json: @check
    end

    # POST /checks
    def create
      check = ChecksHelper.create_check(check_params.to_h)

      if check.nil?
        render :json =>
        { :error => "Unprocessable Entity"},
          status: :unprocessable_entity
        return
      else
        render json: check, status: :created, location: [:v1, check]
      end

      ChecksEnqueueJob.perform_later([check], check.created_at.to_s)
    end

    # PATCH/PUT /checks/1
    def update
      begin
        if @check.update(check_params)
          if ScansHelper.is_aborted(@check.scan_id) && @check.status == "ASSIGNED"
            render status: :precondition_failed
            return
          end
          render json: @check
        end
      rescue AASM::InvalidTransition
        render :json => { :error => "Unsupported status transition"}, status: :conflict
      rescue Exception
        render json: @check.errors, status: :unprocessable_entity
      end
    end

    # DELETE /checks/1
    def destroy
      @check.deleted_at = DateTime.now
      if @check.save
        render json: @check
      else
        render json: @check.errors, status: :unprocessable_entity
      end
    end

    # POST /checks/1/abort
    def abort
      begin
        @check.abort!
        notify('abort')
        render json: @check
      rescue AASM::InvalidTransition
        render :json => { :error => "Unsupported status transition"}, status: :conflict
      rescue Exception
        render json: @check.errors, status: :unprocessable_entity
      end
    end

    # POST /checks/1/kill
    def kill
      begin
        @check.purge!
        notify('kill')
        render json: @check
      rescue AASM::InvalidTransition
        render :json => { :error => "Unsupported status transition"}, status: :conflict
      rescue Exception
        render json: @check.errors, status: :unprocessable_entity
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_check
      @check = Check.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def check_params
      # NOTE: the :check definition should be in sync with its definition in the
      # ScansController and the scan processor in lib/scan_processor.rb.
      params.require(:check).permit(:target, :status, :options, :webhook, :agent_id, :checktype_id, :checktype_name, :progress, :raw, :report, :scan_id, :jobqueue_id, :jobqueue_name, :tag, :required_vars => [])
    end

    # Notifies action to stream
    def notify(action)
      NotificationsHelper.notify(action: action, check_id: @check.id)
    end
  end
end
