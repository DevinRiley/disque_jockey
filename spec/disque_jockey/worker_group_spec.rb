require 'spec_helper'
require 'disque_jockey/worker_shared_setup'
module DisqueJockey
  describe WorkerGroup do
    include_context "worker setup"
    subject { WorkerGroup }

    describe "work!" do
      before(:each) do
        @worker_classes = [SpecWorker, SecondSpecWorker]
        allow_any_instance_of(Broker).to receive(:acknowledge).and_return(true)
        # stub out the method that loops forever so we can get on with our tests
        allow_any_instance_of(subject).to receive(:work_until_signal) do
          # We sleep here so that the job has time to run before we return from
          # this method.  I'm sure there is a better way to do this.
          sleep(0.01)
        end
      end

      it "can be instantiated without errors" do
        expect{subject.new([SpecWorker]).work!}.to_not raise_error
      end

      it "instantiates the correct number of workers" do
        [SpecWorker, SecondSpecWorker].each do |worker_class|
          allow(worker_class).to receive(:new).and_call_original
          expect(worker_class).to receive(:new).exactly(worker_class.thread_count).times
        end
        subject.new(@worker_classes).work!
      end
    end

  end
end