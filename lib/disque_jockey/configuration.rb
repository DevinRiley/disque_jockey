module DisqueJockey
  class Configuration

    attr_accessor :logger, :worker_groups, :log_path, :env, :nodes

    def initialize
      # set defaults
      @worker_groups = 2
      @log_path = (env == 'test' ? 'spec/log' : 'log')
      @nodes = ["127.0.0.1:7711"]
    end

    def env
      @env ||= ENV['DISQUE_JOCKEY_ENV'] || 'development'
    end

    def daemonize?
      env != 'development'
    end

  end
end

