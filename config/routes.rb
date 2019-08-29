Rails.application.routes.draw do
  scope module: 'api' do
    namespace :v1 do
      resources :checks do
        member do
          post 'report'
          post 'raw'
          post 'abort'
          post 'kill'
        end
      end
      resources :agents do
        member do
          post 'heartbeat'
          post 'disconnect'
          post 'pause'
          post 'resume'
        end
      end
      resources :jobqueues
      resources :assettypes
      resources :checktypes
      resources :scans do
        member do
          get 'checks'
          get 'stats'
          post 'abort'
        end
      end
      post 'filescan' => 'filescan#create'
    end
  end
  get 'status' => 'healthchecks#health'
end
