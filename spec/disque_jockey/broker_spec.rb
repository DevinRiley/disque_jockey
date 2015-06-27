require 'spec_helper'
module DisqueJockey
  describe Broker do
    # Note: You actually have to run a Disque server
    # locally for these tests to pass
    before(:all) do
      begin
        @broker = Broker.new
        @client = Disque.new(["127.0.0.1:7711"])
      rescue ArgumentError => error
        raise ArgumentError, "#{error}. You need to run a Disque server on 127.0.0.1:7711 for these test to pass."
      end
    end

    # This will flush all queues -- potentially really dangerous.
    # hopefully we can just flush test queues in the future.
    after(:all) { @client.call('DEBUG', 'FLUSHALL') }

    it "::new takes an array of hosts but provides a default" do
      expect{ Broker.new }.to_not raise_error
      expect{ Broker.new(["127.0.0.1:7711"]) }.to_not raise_error
    end

    it "::new passes on args to Disque client" do
      expect(Disque).to receive(:new).with(['0.0.0.0'], auth: 'secret')
      Broker.new(['0.0.0.0'], auth: 'secret')
    end

    it "#fetch_message_from delivers messages" do
      @client.push("test_queue", "job", 1000)
      result = @broker.fetch_message_from('test_queue')
      expect(result).to be_kind_of(Array)
      expect(result).to include('test_queue', 'job')
    end

    describe '#acknowledge' do
      it "removes job from queue and returns true if it succeeds" do
        @client.call('DEBUG', 'FLUSHALL')
        job_id = @client.push('test_queue', 'test job', 1000)
        expect(@client.call('QLEN', 'test_queue')).to eq 1
        expect(@broker.acknowledge(job_id)).to eq true
        expect(@client.call('QLEN', 'test_queue')).to eq 0
      end

      it "raises an error for a bad job id" do
        expect{ @broker.acknowledge('bad_id') }.to raise_error(RuntimeError)
      end
    end

    describe "#publish" do
      it "publishes a job to Disque" do
        test_queue = 'publish_test_queue'
        test_job = 'job'
        @broker.publish(test_queue, test_job, 1000)
        fetched = @client.fetch(from: ['publish_test_queue']).first
        expect(fetched.first).to eq test_queue
        expect(fetched.last).to eq test_job
      end
    end

    describe "#fast_acknowledge" do
      it "raises an error for a bad job id" do
        expect{@broker.fast_acknowledge('bad_id')}.to raise_error(RuntimeError)
      end

      it "acknowledges jobs" do
        @client.call('DEBUG', 'FLUSHALL')
        job_id = @client.push('test_queue', 'test job', 1000)
        expect(@client.call('QLEN', 'test_queue')).to eq 1
        expect(@broker.fast_acknowledge(job_id)).to eq true
        expect(@client.call('QLEN', 'test_queue')).to eq 0
      end
    end

  end
end
