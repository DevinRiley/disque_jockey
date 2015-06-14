module DisqueJockey
  class Configuration
    attr_accessor :logger, :worker_groups, :log_path, :env
    def initialize
      # set defaults
      @worker_groups = worker_groups_for_environment
      @log_path = log_path_for_environment
    end

    def env
      @env ||= ENV['DISQUE_JOCKEY_ENV'] || 'development'
    end

    def daemonize?
      env != 'development'
    end

    def log_path_for_environment
      env == 'test' ? 'spec/log' : 'log'
    end

    # TODO: just read this from a config file
    def worker_groups_for_environment
      env == 'development' ? 2 : 4
    end

  end
end

