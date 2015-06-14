require 'disque_jockey/version'
require 'disque_jockey/broker'
require 'disque_jockey/logger'
require 'disque_jockey/supervisor'
require 'disque_jockey/worker'
require 'disque_jockey/configuration'
require 'disque_jockey/worker_pool'
require 'disque_jockey/worker_group'
require 'timeout'


module DisqueJockey
  # raise exceptions in all threads so we don't fail silently
  Thread.abort_on_exception = true

  def self.configuration
    @configuration ||= DisqueJockey::Configuration.new
  end

  def self.configure
    yield(self.configuration)
  end

  def self.run!
    DisqueJockey::Supervisor.work!
  end
end