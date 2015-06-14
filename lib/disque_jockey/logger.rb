require 'logging'

module DisqueJockey
  class Logger

    def initialize(klass)
      init_color_scheme
      @logger = Logging.logger[klass]
      @logger.add_appenders(*log_appenders)
      @logger.level = :info
    end

    def logger
      @logger
    end

    # logging levels
    def fatal(message)
      @logger.fatal(message)
    end

    def error(message)
      @logger.error(message)
    end

    def warn(message)
      @logger.warn(message)
    end

    def info(message)
      @logger.info(message)
    end

    def debug(message)
      @logger.debug(message)
    end

    private

    def log_appenders
      appenders = []
      appenders << file_appender
      appenders << stdout_appender if DisqueJockey.configuration.env == 'development'
      return appenders
    end

    def file_appender
      begin
        Logging.appenders.file("#{DisqueJockey.configuration.log_path}/#{DisqueJockey.configuration.env}.log",
          { layout: Logging.layouts.pattern(log_pattern) })
      rescue
        raise "You must provide a valid log path and log file!  DisqueJockey by default will log to the current directory /log/environment.log.  Make sure that directory exists and the file is writeable!. Configure DisqueJockey's log path before running if you'd like to specify a custom path"
      end
    end

    def stdout_appender
      # only add colors to the STDOUT appender to prevent color codes
      # from getting into the log files and potentially impacting commands
      # like 'less' and 'more'
      Logging.appenders.stdout({ layout: Logging.layouts.pattern(log_pattern.merge(color_scheme: 'bright')) })
    end

    def log_pattern
      { pattern: '[%d] %-5l %c: %m\n' }
    end

    def init_color_scheme
      Logging.color_scheme('bright',
      :levels => {
        :info  => :green,
        :warn  => :yellow,
        :error => :red,
        :fatal => [:white, :on_red]
      },
      :date => :blue,
      :logger => :magenta,
      :message => :white
      )
    end

  end
end

