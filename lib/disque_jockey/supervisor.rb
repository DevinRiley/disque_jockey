module DisqueJockey
  class Supervisor

    def self.work!
      Process.daemon(true) if DisqueJockey.configuration.daemonize?
      load_workers
      spawn_worker_groups
      trap_signals_in_parent
      monitor_worker_groups
    end

    def self.logger
      @logger ||= DisqueJockey::Logger.new('DisqueJockey')
    end  

    def self.worker_classes
      @worker_classes ||= []
    end

    private

    def self.child_pids
      @child_pids ||= []
    end

    def self.register_worker(worker_class)
      worker_classes.push(worker_class)
    end

    def self.load_workers
      Dir.glob('**/workers/*.rb') {|f| require File.expand_path(f)}
    end

    def self.spawn_worker_groups
      DisqueJockey.configuration.worker_groups.times { spawn_worker_group }
    end

    def self.spawn_worker_group
      child_pids << Process.fork { WorkerGroup.new(worker_classes).work! }
    end

    def self.monitor_worker_groups
      # this method never returns, it just
      # spawns new worker groups if their
      # processes exit.
      # DisqueJockey only exits if it receives a 
      # kill signal
      loop do
        @dead_disque_jockeys.each do
          child_pid = @dead_disque_jockeys.shift
          logger.error "Child worker group exited: #{child_pid}"
          child_pids.delete(child_pid)
          spawn_worker_group
        end
        sleep(0.1)
      end
    end

    def self.trap_signals_in_parent
      @dead_disque_jockeys = []
      %w(QUIT TERM INT ABRT CLD).each do |sig|
        trap(sig) do
          if sig == 'CLD'
            # if a child process dies, we want to 
            # respawn another worker group
            # This needs to be reentrant, so we queue up dead child
            # processes to be handled in the run loop, rather than 
            # acting here
            @dead_disque_jockeys << Process.wait
          else 
            begin
              child_pids.each { |pid| Process.kill(sig, pid) }
            ensure exit
            end
          end

        end
      end
    end



  end
end