require "thor"

module DisqueJockey
  class CLI < Thor
    desc "start", "Start disque_jockey"
    option :env, :desc => "set environment"
    option :worker_groups, :desc => "set number of worker groups"
    option :log_path, :desc => "set path to logs"
    option :nodes, :desc => "set nodes"
    option :daemonize, :type => :boolean, :desc => "run disque_jockey as daemon"
    long_desc DisqueJockey::CLI::Help.start

    def start
      DisqueJockey.run!(options)
    end
  end
end

