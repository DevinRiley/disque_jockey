require 'spec_helper'

describe DisqueJockey::Configuration do
  context 'development' do
    before { ENV['DISQUE_JOCKEY_ENV'] = 'development' }
    after {  ENV['DISQUE_JOCKEY_ENV'] = 'test' }
    subject { DisqueJockey::Configuration.new }

    it { expect(subject.daemonize?).to eq false }
  end

  describe "provides configurable attributes" do
    it { expect(subject).to respond_to(:log_path) }
    it { expect(subject).to respond_to(:log_path=) }
    it { expect(subject).to respond_to(:nodes) }
    it { expect(subject).to respond_to(:nodes=) }
    it { expect(subject).to respond_to(:worker_groups) }
    it { expect(subject).to respond_to(:worker_groups=) }
    it { expect(subject).to respond_to(:log_path) }
    it { expect(subject).to respond_to(:log_path=) }
    it { expect(subject).to respond_to(:env) }
    it { expect(subject).to respond_to(:env=) }
  end
end
