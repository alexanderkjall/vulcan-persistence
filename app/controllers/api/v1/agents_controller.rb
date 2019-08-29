module Api::V1
  class AgentsController < ApplicationController
    before_action :set_agent, only: [:show, :update, :destroy, :heartbeat, :disconnect, :pause, :resume]

    # GET /agents
    def index
      @agents = Agent.where(deleted_at: nil).filter(params.slice(:status, :enabled, :jobqueue_id, :no_heartbeat_since))

      render json: @agents
    end

    # GET /agents/1
    def show
      render json: @agent
    end

    # POST /agents
    def create
      @agent = Agent.new(agent_params)

      if @agent.save
        render json: @agent, status: :created, location: [:v1, @agent]
      else
        render json: @agent.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /agents/1
    def update
      if @agent.update(agent_params)
        if @agent.status == 'REGISTERING'
          notify('register')
        end
        render json: @agent
      else
        render json: @agent.errors, status: :unprocessable_entity
      end
    end

    # DELETE /agents/1
    def destroy
      @agent.deleted_at = DateTime.now
      if @agent.save
        render json: @agent
      else
        render json: @agent.errors, status: :unprocessable_entity
      end
    end

    # POST /agents/1/heartbeat
    def heartbeat
      @agent.heartbeat_at = DateTime.now
      if @agent.save
        render json: @agent
      else
        render json: @agent.errors, status: :unprocessable_entity
      end
    end

    # POST /agents/1/disconnect
    def disconnect
      begin
        @agent.disconnect!
        notify('disconnect')
        render json: @agent
      rescue AASM::InvalidTransition
        render :json => { :error => "Unsupported status transition"}, status: :conflict
      rescue Exception
        render json: @agent.errors, status: :unprocessable_entity
      end
    end

    # POST /agents/1/pause
    def pause
      begin
        @agent.dopause!
        notify('pause')
        render json: @agent
      rescue AASM::InvalidTransition
        render :json => { :error => "Unsupported status transition"}, status: :conflict
      rescue Exception
        render json: @agent.errors, status: :unprocessable_entity
      end
    end

    # POST /agents/1/resume
    def resume
      begin
        @agent.doresume!
        notify('resume')
        render json: @agent
      rescue AASM::InvalidTransition
        render :json => { :error => "Unsupported status transition"}, status: :conflict
      rescue Exception
        render json: @agent.errors, status: :unprocessable_entity
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_agent
      @agent = Agent.find(params[:id])
    end

    def notify(action)
      NotificationsHelper.notify(action: action, agent_id: @agent.id)
    end

    # Only allow a trusted parameter "white list" through.
    def agent_params
      params.require(:agent).permit(:status, :jobqueue_id, :version, :enabled, :heartbeat_at)
    end
  end
end
