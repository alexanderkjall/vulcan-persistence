class HealthchecksController < ApplicationController
  def health
    if ActiveRecord::Base.connection.execute('select 1;')
      render status: :ok
    else
      render status: :internal_server_error
    end
  end
end
