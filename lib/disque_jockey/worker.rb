module DisqueJockey
  class Worker
    attr_reader :logger
    def initialize(logger)
      @logger = logger.new(self.class.to_s + rand(1000).to_s)
    end

    def log_exception(e)
      logger.error "#{self.class} raised exception #{e.inspect}: "
      logger.error ">   " + e.backtrace.reject{|l| l =~ /\.rvm/ }.join("\n>   ")
    end

    class << self
      attr_reader :queue_name, :thread_count, :timeout_seconds, :use_fast_ack

      # This worker class will subscribe to queue
      def subscribe_to(queue)
        @queue_name = queue
      end

      # whehter to use Disque fast acknowledgements
      def fast_ack(value)
        @use_fast_ack = !!value
      end

      # minimum number of worker instances of a given worker class.
      def threads(size)
        @thread_count = [[size, 1].max, 10].min
      end

      # seconds to wait for a job to be handled before timing out the worker.
      # (capped between 0.01 seconds and one hour)
      def timeout(seconds)
        @timeout_seconds = [[seconds, 0.01].max, 3600].min
      end

      protected

      # callback method fired when a class inherits from DisqueJockey::Worker
      def inherited(type)
        # these are the defaults
        type.threads 2
        type.timeout 30
        type.fast_ack false
        # register the new worker type so we can start giving it jobs
        Supervisor.register_worker(type)
      end
    end

  end
end
