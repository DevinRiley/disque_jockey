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

  context "when there are no command line options" do
    it "uses configuration defaults" do
      config = DisqueJockey::Configuration.new({})
      
      expect(config.daemonize).to be true
      expect(config.env).to eq("test")
      expect(config.log_path).to eq("spec/log")
      expect(config.nodes).to eq(["127.0.0.1:7711"])
      expect(config.worker_groups).to eq(2)
    end
  end

  context "when there are command line options" do
    it "sets them in the configuration" do
      cli_opts = {
        "env" => "production",
        "daemonize" => true,
        "worker_groups" => "10",
        "nodes" => "324.545.23.12:5453,98.437.437.23:43534"
      }
      config = DisqueJockey::Configuration.new(cli_opts)
      expect(config.daemonize).to be true
      expect(config.env).to eq("production")
      expect(config.log_path).to eq("log")
      expect(config.nodes).to eq(["324.545.23.12:5453","98.437.437.23:43534"])
      expect(config.worker_groups).to eq(10)
    end
  end
end

