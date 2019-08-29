class Check < ApplicationRecord
  # checktype_name is a virtual attribute, not persisted in the model.
  attr_accessor :checktype_name

  include Filterable
  include AASM

  after_commit :sns_publish
  before_update :verify_state_machine

  belongs_to :agent
  belongs_to :checktype
  belongs_to :scan, optional: true
  validates :checktype_id, :presence => true
  validates :target, :presence => true

  scope :status, -> (status) { where status: status }
  scope :target, -> (target) { where target: target }
  scope :checktype_id, -> (checktype_id) { where checktype_id: checktype_id }
  scope :agent_id, -> (agent_id) { where agent_id: agent_id }

  aasm :column => :status do
    state :CREATED, :initial => true
    state :QUEUED
    state :ASSIGNED
    state :MALFORMED
    state :RUNNING
    state :FAILED
    state :FINISHED
    state :ABORTED
    state :PURGING
    state :KILLED
    state :TIMEOUT

    # Enqueue is the event of a check being added to the queue.
    event :enqueue do
      transitions :from => :CREATED, :to => :QUEUED
    end
    # Assign is the event of an agent taking ownership of a check.
    event :assign do
      transitions :from => :QUEUED, :to => :ASSIGNED
    end
    # Malform is the event of an agent marking a check job as malformed.
    event :malform do
      transitions :from => :ASSIGNED, :to => :MALFORMED
    end
    # Timeout is the event of a check that has timed out.
    event :timeout do
      transitions :from => :RUNNING, :to => :TIMEOUT
    end
    # Run is the event of an agent running a check in its runtime environment.
    event :run do
      transitions :from => :ASSIGNED, :to => :RUNNING
    end
    # Abort is the event of confirming the abortion of a check.
    event :abort do
      transitions :from => [:CREATED , :ASSIGNED, :RUNNING], :to => :ABORTED
    end
    # Purge is the event of a check being flagged to be killed.
    # This event is ment to be triggered by a janitor service.
    event :purge do
      transitions :from => :RUNNING, :to => :PURGING
    end
    # Kill is the event of an agent confirming that a check is killed.
    # This can happen because a check was scheduled to be purged,
    # because the check could not be successfully aborted cleanly or
    # because the agent has disconnected and is purging all running checks.
    event :kill do
      transitions :from => [:RUNNING, :PURGING], :to => :KILLED
    end
    # Fail is the event of a check failing for any reason.
    event :fail do
      transitions :from => [:ASSIGNED, :RUNNING], :to => :FAILED
    end
    # Finish is the event of a check finishing successfully.
    event :finish do
      transitions :from => :RUNNING, :to => :FINISHED
    end
  end

  def sns_publish()
    SNSPublishJob.perform_later(self)
  end

  private
  def verify_state_machine
    if status
      db_check = Check.find(id)
      # There is a status change. Need to check state machine
      if db_check[:status] != self[:status]
        case self[:status]
        when "QUEUED"
          db_check.enqueue
        when "ASSIGNED"
          db_check.assign
        when "MALFORMED"
          db_check.malform
        when "RUNNING"
          db_check.run
        when "TIMEOUT"
          db_check.timeout
        when "FAILED"
          db_check.fail
        when "ABORTED"
          db_check.abort
        when "PURGING"
          db_check.purge
        when "KILLED"
          db_check.kill
        when "FINISHED"
          db_check.finish
        end
      end
    end
  end
end
