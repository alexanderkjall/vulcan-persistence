require 'json/stream'

class ScanProcessor

  @@State = Struct.new(:status, :check, :key, :processor)

  def initialize(logger, check_parsed)
    @logger = logger
    @check_parsed = check_parsed
    me = self
    @parser = JSON::Stream::Parser.new do
      start_document { me.process_event(:startdoc) }
      end_document   { me.process_event(:edoc) }
      start_object   { me.process_event(:sobject) }
      end_object     { me.process_event(:eobject) }
      start_array    { me.process_event(:sarray) }
      end_array      { me.process_event(:earray) }
      key            { |k| me.process_event(:skey, k) }
      value          { |v| me.process_event(:sval, v) }
    end
    @state = @@State.new
    @state.processor = method(:begin)
    @state.check = nil
    @state.key = nil
  end

  def process_event(event, event_data = nil)
    @state.processor.call event, event_data
  end

  def begin(event, event_data = nil)
    if event == :skey && event_data == 'checks'
      @state.processor = method(:process_checks_array)
    end
  end

  def process_checks_array(event, event_data = nil)
    if event == :skey && event_data == 'check'
      @state.processor = method(:process_check)
      @state.check = { checktype_id: '', checktype_name: '', target: '', options: '', webhook: '', tag:nil, jobqueue_id:nil, jobqueue_name:nil, required_vars: []}.with_indifferent_access
    end
  end

  def process_check(event, event_data = nil)
    @state.key = event_data if event == :skey
    if event == :sval && @state.check.key?(@state.key)
      @state.check[@state.key] =  event_data
    end

    if event == :val && !@state.check.key?(@state.key)
      @logger.warn "Found unknown key while parsing check in scan file: #{@state.key}, skipping key."
    end

    if event == :eobject
      @state.processor = method(:process_checks_array)
      @check_parsed.call @state.check
    end
  end

  def receive_data(data)
   @parser << data
  rescue JSON::Stream::ParserError => e
    @logger.error e.to_s
  end
end
