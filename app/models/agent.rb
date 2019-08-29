class Agent < ApplicationRecord
  include Filterable
  include AASM

  has_many :checks
  belongs_to :jobqueue
  validates :jobqueue_id, :version, :presence => true

  scope :status, -> (status) { where status: status }
  scope :enabled, -> (enabled) { where enabled: enabled }
  scope :jobqueue_id, -> (jobqueue_id) { where jobqueue_id: jobqueue_id }
  scope :no_heartbeat_since, -> (no_heartbeat_since) { where("heartbeat_at < ?", Time.now - no_heartbeat_since.to_i.seconds) }

  aasm :column => :status do
    state :NEW, :initial => true
    state :REGISTERING
    state :REGISTERED
    state :PAUSING
    state :PAUSED
    state :RESUMING
    state :RUNNING
    state :DISCONNECTED
    state :PURGING
    state :DOWN

    # Preregister is the event of creating an agent in the
    # persistence service awaiting registration confirmation.
    event :preregister do
      transitions :from => :NEW, :to => :REGISTERING
    end
    # Register is the event of confirming registration
    # through a stream event received by the agent.
    event :register do
      transitions :from => :REGISTERING, :to => :REGISTERED
    end
    # Run is the event of an agent handling jobs.
    event :run do
      transitions :from => :REGISTERED, :to => :RUNNING
    end
    # Dopause notifies an agent that should stop getting jobs from the queue
    event :dopause do
      transitions :from => :RUNNING, :to => :PAUSING
    end
    # Pause is the event of an agent stop getting jobs from the queue
    event :pause do
      transitions :from => :PAUSING, :to => :PAUSED
    end
    # Doresume notifies an agent that should start getting jobs from the queue
    event :doresume do
      transitions :from => :PAUSED, :to => :RESUMING
    end
    # Resume is the event of an agent handling jobs.
    event :resume do
      transitions :from => :RESUMING, :to => :RUNNING
    end
    # Disconnect is the event of an agent disconnecting.
    event :disconnect do
      transitions :from => [:RUNNING, :PAUSED], :to => :DISCONNECTED
    end
    # Purge is the event of an agent killing all running checks.
    event :purge do
      transitions :from => :DISCONNECTED, :to => :PURGING
    end
    # Shutdown is the event of an agent shutting down.
    # An agent is free to go down from any state. The reason for this is
    # to prevent that an agent is left hanging in a transitory state.
    event :shutdown do
      transitions :from => [:NEW, :REGISTERING, :REGISTERED, :RUNNING, :DISCONNECTED, :PURGING], :to => :DOWN
    end
  end
end
