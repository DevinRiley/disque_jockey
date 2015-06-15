# A WorkerGroup lives in its own process
# and runs workers of each worker class.  It is effectively
# a self-contained unit of workers that fetch jobs and work.
module DisqueJockey
  class WorkerGroup

    def initialize(worker_classes = [])
      @worker_classes = worker_classes # array of classes to instantiate in our group
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

    # for each worker class, create a worker pool and have
    # them start fetching jobs and working
    def start_workers
      @worker_classes.each do |worker_class|
        Thread.new { WorkerPool.new(worker_class).work! }
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

  end
end