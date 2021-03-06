require 'disque'
module DisqueJockey
  class Broker

    def initialize(nodes = ["127.0.0.1:7711"], *args)
      @client = Disque.new(nodes, *args)
    end

    def fetch_message_from(queue)
      # fetch returns an array of jobs, but we just want the first one
      @client.fetch(from: [queue]).first
    end

    def acknowledge(job_id)
      response = @client.call('ACKJOB', job_id)
      raise_error_or_return_true(response)
    end

    def fast_acknowledge(job_id)
      response = @client.call('FASTACK', job_id)
      raise_error_or_return_true(response)
    end

    def publish(*args)
      @client.push(*args)
    end

    private

    # If there is an error acking the job the Disque client
    # *returns* an error object but doesn't raise it,
    # so we raise it here ourselves.
    def raise_error_or_return_true(response)
      response.is_a?(RuntimeError) ? raise(response) : true
    end

  end
end
