require 'spec_helper'
require 'disque_jockey/worker_shared_setup'

module DisqueJockey
  describe WorkerPool do
    include_context "worker setup"

    before(:each) do
      allow_any_instance_of(Broker).to receive(:fetch_message_from).and_return(['dummy', 'test_id', 'test job'])
      allow_any_instance_of(Broker).to receive(:acknowledge)
      allow_any_instance_of(WorkerPool).to receive(:endless_loop).and_yield
      allow(Thread).to receive(:new).and_yield
    end

    it "instantiates the number of workers specified" do
      expect(SpecWorker).to receive(:new).exactly(SpecWorker.thread_count).times
      described_class.new(SpecWorker)
    end

    it "instantiates brokers with nodes from configuration" do
      expect(Broker).to receive(:new).with(DisqueJockey.configuration.nodes)
      described_class.new(SpecWorker)
    end

    it "gives workers jobs to perform" do
      @mock_worker = double("Worker", handle: true)
      @mock_worker_class = double("WorkerClass", thread_count: 1, new: @mock_worker, timeout_seconds: 1, queue_name: 'q')
      worker_pool = WorkerPool.new(@mock_worker_class)
      expect(@mock_worker).to receive(:handle)
      worker_pool.work!
    end

    it "times out workers that take too long" do
      expect_any_instance_of(SlowWorker).to receive(:log_exception).at_least(:once)
      WorkerPool.new(SlowWorker).work!
    end

    it "acknowledges jobs if they are processed without errors" do
      expect_any_instance_of(Broker).to receive(:acknowledge).with('test_id').at_least(:once)
      WorkerPool.new(SecondSpecWorker).work!
    end

  end
end