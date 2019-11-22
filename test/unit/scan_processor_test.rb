require 'test_helper'

describe 'scan_processor' do
  it 'should process a scan' do
    checks_params = { scan: { checks: [
      { check: { checktype_name: 'tls', target: 'localhost', tag:'tag1'}},
      { check: { checktype_name: 'tls', target: 'www.example.com', tag:'tag2'}}
    ]}}
    s = StringIO.new checks_params.to_json.to_s
    processor = ScanProcessor.new(Rails.logger, method(:check_parsed))
    s.each(nil, 10) do |chunk|
      processor.receive_data(chunk)
    end

    assert_equal(@checks,[
                   { 'checktype_id' => '', 'checktype_name' => 'tls', 'target' => 'localhost', 'options' => '', 'webhook' => '', 'tag' => 'tag1', 'jobqueue_id' => nil, 'jobqueue_name' => nil, 'required_vars' => []},
                   { 'checktype_id' => '', 'checktype_name' => 'tls', 'target' => 'www.example.com', 'options' => '', 'webhook' => '', 'tag' => 'tag2', 'jobqueue_id' => nil, 'jobqueue_name' => nil, 'required_vars' => []}
                 ])
  end
  def check_parsed(check)
    @checks = [] if @checks.nil?
    @checks << check
  end
end
