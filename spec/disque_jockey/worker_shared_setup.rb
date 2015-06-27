shared_context "worker setup" do

  before(:all) do

    class SpecWorker < DisqueJockey::Worker
      subscribe_to "test"
      def handle(job); end
    end

    class SecondSpecWorker < DisqueJockey::Worker
      subscribe_to "other-test"
      fast_ack true
      threads 1
      timeout 1
      def handle(job); end
    end

    class SlowWorker < DisqueJockey::Worker
      subscribe_to "slow-test"
      timeout 0.01
      threads 1
      def handle(job); sleep(0.1); end
    end

  end
end
