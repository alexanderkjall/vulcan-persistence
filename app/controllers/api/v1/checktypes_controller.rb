module Api::V1
  class ChecktypesController < ApplicationController
    before_action :set_checktype, only: [:show, :update, :destroy]

    # GET /checktypes[?enabled=false&name=nmap]
    def index
      if params[:name]
        @checktype = Checktype.where(name: params[:name], enabled: true, deleted_at: nil).order('created_at DESC').first
        render json: @checktype
      else
        @checktypes = Checktype.where(deleted_at: nil).filter(params.slice(:checktype, :required_vars, :image, :assets, :enabled))
        render json: @checktypes
      end
    end

    # GET /checktypes/1
    def show
      render json: @checktype
    end

    # POST /checktypes
    def create
      @checktype = Checktype.new(checktype_params)
      if @checktype.save
        render json: @checktype, status: :created, location: [:v1, @checktype]
      else
        render json: @checktype.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /checktypes/1
    def update
      if @checktype.update(checktype_params)
        render json: @checktype
      else
        render json: @checktype.errors, status: :unprocessable_entity
      end
    end

    # DELETE /checktypes/1
    def destroy
      @checktype.deleted_at = DateTime.now
      if @checktype.save
        render json: @checktype
      else
        render json: @checktype.errors, status: :unprocessable_entity
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_checktype
      @checktype = Checktype.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def checktype_params
      params.require(:checktype).permit(:name, :description, :timeout, :enabled, :options, :image, :queue_name, :assets => [], :required_vars => [])
    end
  end
end
