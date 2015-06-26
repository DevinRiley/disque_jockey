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
      # If there is an error acking the job the Disque client
      # *returns* an error object but doesn't raise it,
      # so we raise it here ourselves.
      response.is_a?(RuntimeError) ? raise(response) : true
    end

    def publish(*args)
      @client.push(*args)
    end
  end
end
