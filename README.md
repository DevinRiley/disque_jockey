# DisqueJockey
DisqueJockey is a fast, concurrent background job processing framework for the Disque message queue.

## Installation
First, you should run a Disque server if you aren't already doing so.
Disque source and build instructions can be found at: https://github.com/antirez/disque

Once Disque is set up:
````
git clone git@github.com:DevinRiley/disque_jockey.git
````

cd into the project directory
Install the gem dependencies with bundler
````
bundle install
````

to build the gem:
````
rake build
````

to install the gem on your machine:
````
gem install pkg/disque_jockey-0.0.1.gem
````

Now you're ready to use disque_jockey!

## Writing your first worker
DisqueJockey provides a framework for creating background task workers.  Workers subscribe to a disque queue and are given jobs from the queue.

Your worker should inherit from the DisqueJockey::Worker class

```ruby
require 'disque_jockey'
class ExampleWorker < DisqueJockey::Worker
  subscribe_to 'example-queue'
  def handle(job)
    logger.info("Peforming job: #{job}")
  end
end
```
Your worker class must do two things:
- call the subscribe_to method with the name of a queue
- implement a handle method, which will take a job as its argument. Jobs from Disque are strings.


Lastly, you must place your worker in a directory named 'workers'

## Starting Disque Jockey
Once your worker is written and placed in a workers directory, you can call `disque_jockey start` from the command line and it will start up your workers and begin delivering jobs to them.

To see all the command line options, use the help command:
```
disque_jockey help start
```

To start disque_jockey with the desired options:
````
disque_jockey start --env=production --daemonize=true --worker-groups=10  --nodes=127.0.0.1:7111,34.45.231.124:4242
````

Messages successfully handled by a worker (ie no exceptions raised from the handle method) will be acknowledged and removed from the queue.

##Roadmap:
DisqueJockey is not a currently a production-ready system, and there are a number of goals for it that have not been met yet.
Here is a list of functionality I'd like to add to DisqueJockey in the near future:
- Allow workers to set auto-acknowledge or fast-acknowledge of messages.
- Better test coverage around worker groups
- Rails integration (ActiveJob Adapter)
- More use cases in the README (e.g. how to use alongside Rails)
