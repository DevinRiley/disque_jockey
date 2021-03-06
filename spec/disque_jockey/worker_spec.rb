require 'spec_helper'
require 'disque_jockey'
require 'disque_jockey/worker_shared_setup'

describe DisqueJockey::Worker do
  include_context "worker setup"

  it "defines class methods" do
    [ :queue_name, :thread_count, :timeout_seconds,
      :subscribe_to, :timeout, :threads, :fast_ack, :use_fast_ack
    ].each do |method|
      expect(DisqueJockey::Worker).to respond_to(method)
    end
  end

  it "defines logger method" do
     expect(DisqueJockey::Worker.instance_methods.include?(:logger)).to eq(true)
  end

  it "keeps track of classes that subclass it" do
    initial_subclass_count = DisqueJockey::Supervisor.worker_classes.length
    class ChildWorker < DisqueJockey::Worker; end
    expect(DisqueJockey::Supervisor.worker_classes.length).to eq (initial_subclass_count + 1)
  end

  context "defaults" do
    it "timeout is 30 seconds" do
      expect(SpecWorker.timeout_seconds).to be(30)
    end

    it "thread_count is 2" do
      expect(SpecWorker.thread_count).to be(2)
    end

    it "use_fast_ack is false" do
      expect(SpecWorker.use_fast_ack).to eq false
    end

  end

  context "class methods"
  context "overrides" do

    it "allows overrides for timeout, threads, and fast_ack" do
      # These traits are set in worker_shared_setup.rb
      expect(SecondSpecWorker.timeout_seconds).to be(1)
      expect(SecondSpecWorker.thread_count).to be(1)
      expect(SecondSpecWorker.use_fast_ack).to be(true)
    end
  end

  context "instance methods"
  describe "#initialize" do
    before do
      @logger = double(:logger, info: true, error: true, warn: true)
      allow(@logger).to receive(:new).and_return(@logger)
    end

    it "sets a logger" do
      worker = SpecWorker.new(@logger)
      expect(worker.logger).to_not be_nil
    end
  end
end

