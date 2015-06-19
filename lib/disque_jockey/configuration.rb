module DisqueJockey
  class Configuration

    attr_accessor :logger, :worker_groups, :log_path, :env, :nodes, :daemonize

    def initialize(options={})
      @env = options["env"] || ENV["DISQUE_JOCKEY_ENV"] || "development"
      @worker_groups = options["worker_groups"] || 2
      @log_path = options["log_path"] || log_path_default
      @nodes = parse_nodes(options["nodes"]) || ["127.0.0.1:7711"]
      @daemonize = options["daemonize"] || daemonize_default
    end

    def daemonize?
      @daemonize
    end

    private

    def parse_nodes(nodes)
      return unless nodes
      nodes.split(",")
    end

    def log_path_default
      env == "test" ? "spec/log" : "log"
    end

    def daemonize_default
      env != 'development'
    end
  end
end

