require 'spec_helper'

describe DisqueJockey::Configuration do
  context 'development' do
    before { ENV['DISQUE_JOCKEY_ENV'] = 'development' }
    after {  ENV['DISQUE_JOCKEY_ENV'] = 'test' }
    subject { DisqueJockey::Configuration.new }

    it { expect(subject.daemonize?).to eq false }
  end

  it "defines a log path method" do
    expect(DisqueJockey::Configuration.new).to respond_to(:log_path)
    expect(DisqueJockey::Configuration.new).to respond_to(:log_path=)
    config = DisqueJockey::Configuration.new
    config.log_path = 'spec-path'
    expect(config.log_path).to eq 'spec-path'
  end
end
