class Check < ApplicationRecord
  # checktype_name is a virtual attribute, not persisted in the model.
  attr_accessor :checktype_name

  include Filterable
  include AASM

  after_commit :sns_publish
  before_update :verify_state_machine
  # In case the transaction is rolled back, we might had push an incorrect metric.
  # Proper hook to push the metric would be after_commit, but then is harder to
  # detect if status has changed. This is the best compromise in effort and consistency.
  after_save :push_check_metrics, if: -> { Rails.application.config.metrics && (status_changed? || new_record?) }

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
  def push_check_metrics
    scan_label = "unknown-program"
    team_label = "unknown-team"
    checktype_label = "unknown-checktype"
    check_status = "unknown-checkstatus"
    scan = Scan.find_by(id: self[:scan_id])
    if scan.nil? || scan.program.blank?
      Rails.logger.warn "error obtaining program name for check [#{self.id}] for pushing metrics"
    else
      scan_label = scan.program.downcase
    end
    if self[:tag].blank?
      Rails.logger.warn "error obtaining team name for check [#{self.id}] for pushing metrics"
      # try to obtain tag from scan
      if scan.nil? || scan.tag.blank?
        Rails.logger.warn "error obtaining team name name for check [#{self.id}] for pushing metrics from scan"
      else
        team_label = scan.tag.split(':').last.downcase
      end
    else
      team_label = self[:tag].split(':').last.downcase
    end
    begin
      checktype_label = self.checktype.name.downcase
    rescue
      Rails.logger.warn "error obtaining checktype name for check [#{self.id}] for pushing metrics"
    end
    begin
      check_status = self.status.downcase
    rescue
      Rails.logger.warn "error obtaining status name for check [#{self.id}] for pushing metrics"
    end

    metric_tags = ["scan:#{team_label}-#{scan_label}", "checktype:#{checktype_label}", "checkstatus:#{check_status}"]
    Metrics.count("scan.check.count", 1, metric_tags)
  end

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
