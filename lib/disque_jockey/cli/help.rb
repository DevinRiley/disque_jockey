require "thor"

module DisqueJockey
  class CLI < Thor
    class Help
      class << self
        def start
          <<-EOL
            Starts disque_jockey processes to start processing Disque jobs.

            Examples:

            $ disque_jockey start --env=production

            $ disque_jockey start --env=development --daemonize=true --work-groups=5

            $ disque_jockey start --nodes=127.0.0.1:6534,54.634.23.43:3452,546.23.124.34:4353
          EOL
        end
      end
    end
  end
end

