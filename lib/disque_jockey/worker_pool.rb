module DisqueJockey
  class WorkerPool

    def initialize(worker_class)
      @worker_class = worker_class
      @pool = Queue.new
      @broker = Broker.new(DisqueJockey.configuration.nodes)
      build_worker_pool
    end

    def work!
      endless_loop do
        # fetching from broker blocks until a job is returned
        _, job_id, job = @broker.fetch_message_from(@worker_class.queue_name)

        with_worker do |worker|
          Thread.new { handle_job(worker, job, job_id) }
        end

      end
    end

    private

    # this method exists so we can stub the endless loop in tests
    def endless_loop
      loop { yield }
    end

    def with_worker
      # @pool.pop will block until a worker becomes available
      worker = @pool.pop
      yield worker
      @pool.push(worker)
    end

    def handle_job(worker, job, job_id)
      begin
        Timeout::timeout(@worker_class.timeout_seconds) { worker.handle(job) }
        @worker_class.use_fast_ack ? @broker.fast_acknowledge(job_id) : @broker.acknowledge(job_id)
      rescue StandardError => exception
        worker.log_exception(exception)
        # TODO: Need to implement retry logic
        #       Also should do more helpful logging around worker timeouts
        #       (explain the error, log the job and maybe metadata)
      end
    end

    def build_worker_pool
      @worker_class.thread_count.times { @pool << @worker_class.new(Logger) }
    end

  end
end
