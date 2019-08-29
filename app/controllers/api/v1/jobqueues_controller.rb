module Api::V1
  class JobqueuesController < ApplicationController
    before_action :set_jobqueue, only: [:show, :update, :destroy]

    # GET /jobqueues
    def index
      @jobqueues = Jobqueue.where(deleted_at: nil).filter(params.slice(:jobqueue_name, :arn))

      render json: @jobqueues
    end

    # GET /jobqueues/1
    def show
      render json: @jobqueue
    end

    # POST /jobqueues
    def create
      if jobqueue_params[:default] && exists_default_jobqueue
        render :json => { :error => "Default jobqueue already exists"}, status: :bad_request
      else
        @jobqueue = Jobqueue.new(jobqueue_params)
        # If there are no jobqueues, first jobqueue is set as default
        if Jobqueue.count == 0
          @jobqueue.default = true
        end
        if @jobqueue.save
          render json: @jobqueue, status: :created, location: [:v1, @jobqueue]
        else
          render json: @jobqueue.errors, status: :unprocessable_entity
        end
      end
    end

    # PATCH/PUT /jobqueues/1
    def update
      if jobqueue_params[:default] && exists_default_jobqueue
        render :json => { :error => "Default jobqueue already exists"}, status: :bad_request
      else
        if @jobqueue.update(jobqueue_params)
          render json: @jobqueue
        else
          render json: @jobqueue.errors, status: :unprocessable_entity
        end
      end
    end

    # DELETE /jobqueues/1
    def destroy
      @jobqueue.deleted_at = DateTime.now
      if @jobqueue.save
        render json: @jobqueue
      else
        render json: @jobqueue.errors, status: :unprocessable_entity
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_jobqueue
      @jobqueue = Jobqueue.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def jobqueue_params
      params.require(:jobqueue).permit(:name, :arn, :description, :default)
    end

    def exists_default_jobqueue
      return Jobqueue.where(deleted_at: nil, default: true).first.present?
    end
  end
end
