# A WorkerGroup lives in its own process
# and runs workers of each worker class.  It is effectively
# a self-contained unit of workers that fetch jobs and work.
module DisqueJockey
  class WorkerGroup

    def initialize(worker_classes = [])
      @worker_classes = worker_classes # array of classes to instantiate in our group
      @worker_pool = {} # initialize a hash for storing workers
    end

    def work!
      register_signal_handlers
      Supervisor.logger.info("Starting worker group with PID #{Process.pid}...")
      start_workers
      work_until_signal
    end

    private

    # This loop is in a method so that we can stub it in tests
    def work_until_signal
      loop do 
        break if handle_signals
        sleep(0.1)
      end
    end

    # Register signal handlers to shut down the worker group.
    def register_signal_handlers
      Thread.main[:signal_queue] = []
      %w(QUIT TERM INT ABRT).each do |signal|
        # This needs to be reentrant, so we queue up signals to be handled
        # in the run loop, rather than acting on signals here
        trap(signal) { Thread.main[:signal_queue] << signal }
      end
    end 

    # instantiate all the workers we want and start giving
    # them jobs to do
    def start_workers
      @worker_classes.each do |worker_class|
        build_worker_pool(worker_class)
        # Each worker_class (and hence, queue), get its own
        # thread because the Disque client library blocks
        # when waiting for a job from a queue.
        Thread.new { fetch_job_and_work(worker_class) }
      end
    end

    # Deal with signals we receive from the OS by logging the signal
    # and then killing the worker group
    def handle_signals
      signal = Thread.main[:signal_queue].shift
      if signal
        Supervisor.logger.info("Received signal #{signal}. Shutting down worker group with PID #{Process.pid}...")
        return true
      end
    end

    # The worker pool gives us a fixed number of worker instances of each class
    # to do the work.  This could be improved by dynamically instantiating
    # and removing workers from the pool based on workload.  For now, we use
    # a fixed number.
    def build_worker_pool(worker_class)
      Supervisor.logger.info("Launching #{worker_class.thread_count} #{worker_class}s")
      worker_class.thread_count.times do
        # Use the Queue class so we access our worker pools
        # from different threads without issues.
        @worker_pool[worker_class] ||= Queue.new
        @worker_pool[worker_class].push worker_class.new(Logger)
      end
    end

    # Here we actually get jobs to work on and hand them off to worker
    # instances.
    def fetch_job_and_work(worker_class)
      broker = Broker.new(DisqueJockey.configuration.nodes)
      loop do
        # this method blocks until a job is returned
        _, job_id, job = broker.fetch_message_from(worker_class.queue_name)
        # Queue#pop will block until a worker becomes available
        worker = @worker_pool[worker_class].pop
        # now that we have a worker, give it a thread to do its work in
        # so we can fetch the next job without waiting.
        Thread.new do
          begin
            # Raise a timeout error if the worker takes too long
            Timeout::timeout(worker_class.timeout_seconds) { worker.handle(job) }
            # acknowlege the job once we've handled it
            broker.acknowledge(job_id)
          rescue StandardError => exception
            worker.log_exception(exception)
            # TODO: Need to implement retry logic
            #       Also should do more helpful logging around worker timeouts
            #       (explain the error, log the job and maybe metadata)
          end
          # We're done working, so put the worker back in the pool
          @worker_pool[worker_class].push(worker)

        end


      end
    end

  end
end