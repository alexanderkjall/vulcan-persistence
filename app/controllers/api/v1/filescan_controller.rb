module Api::V1
    class FilescanController < ApplicationController
      # POST /FileScan
      def create
        @scan = Scan.new
        @scan.tag = params[:tag]
        @scan.program = ScansHelper.normalize_program(params[:program_id])

        if @scan.save
          Filescan.save_scan(@scan.id,params)
          render json: @scan, status: :created, location: [:v1, @scan]
          ScansHelper.push_metric(@scan)
          FilescanProcessJob.perform_later(@scan.id, @scan.created_at.to_s)
        else
          render json: @scan.errors, status: :unprocessable_entity
          return
        end
      end
    end
end
