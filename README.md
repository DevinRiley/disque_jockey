# DisqueJockey
DisqueJockey is a fast, concurrent background job processing framework for the Disque message queue.

######*Warning: This project is still in alpha phase, as is the Disque message queue it relies on.  The API here is not guaranteed to remain the same, nor is this code battle tested or production ready.*

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

Here is a repo of example workers to use as a template: https://github.com/DevinRiley/disque_jockey_examples

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
## Worker Configuration
 DisqueJockey::Worker implements some class methods that help you configure your worker.  You call them the same way you call the `subscribe_to` method, at the top of your class.

```ruby
require 'disque_jockey'
class HighlyConfiguredWorker < DisqueJockey::Worker
  subscribe_to 'example-queue'
  threads 7
  fast_ack true
  timeout 5
  
  def handle(job)
    logger.info("Peforming job: #{job}")
  end
end
```
- *Fast Acknowledgements*: call ````fast_ack true```` to use FASTACKs (https://github.com/antirez/disque#fast-acknowledges) in disque to acknowledge your messages.  Please note that fast_ack will make it more likely you will process a job more than once in the event of a network partition.  fast_ack is false by default.
- *Threads*: To devote more threads to your worker class use ````threads 5```` .  Threads are set to two by default and have a maximum value of 10.
- *Timeout*: To set the number of seconds your worker will process a job until raising a TimeoutError, use ````timeout 45````.  Timeout is set to 30 seconds by default and has a maximum value of 3600 seconds (one hour).

## Using DisqueJockey with Rails
DisqueJockey can be run alongside a Rails app to handle background jobs enqueued by the Rails application. DisqueJockey must be run in a separate process than Rails, so I recommend using the foreman gem to ensure that both processes run together.

First, add foreman and disque_jockey to your rails Gemfile if you haven't already

````ruby
gem 'foreman'
gem 'disque_jockey'
````
Then add your DisqueJockey workers to your rails project inside ```app/workers```

Next, edit your foreman Procfile to run both the rails application and disque_jockey side-by-side
````
web: bundle exec rails s
workers: bundle exec disque_jockey start --daemonize=false
````
note: *its important to run disque_jockey with the ```--daemonize=false``` flag when you are using foreman, otherwise foreman will exit immediately.*

Now when you run ```foreman start``` you should see DisqueJockey logging to STDOUT:
````
11:52:58 web.1     | started with pid 16602
11:52:58 workers.1 | started with pid 16603
11:52:59 workers.1 | [2015-06-27T11:52:59] INFO  DisqueJockey: Starting worker group with PID 16605...
11:52:59 workers.1 | [2015-06-27T11:52:59] INFO  DisqueJockey: Starting worker group with PID 16604...
11:53:02 web.1     | => Booting WEBrick
11:53:02 web.1     | => Rails 4.2.3 application starting in development on http://localhost:3000
11:53:02 web.1     | => Run `rails server -h` for more startup options
11:53:02 web.1     | => Ctrl-C to shutdown server
11:53:02 web.1     | [2015-06-27 11:53:02] INFO  WEBrick 1.3.1
11:53:02 web.1     | [2015-06-27 11:53:02] INFO  ruby 2.2.0 (2014-12-25) [x86_64-darwin14]
11:53:02 web.1     | [2015-06-27 11:53:02] INFO  WEBrick::HTTPServer#start: pid=16602 port=3000
````

Your last step is to enqueue a Disque message inside your rails application and watch your workers handle it.

````ruby
class BackgroundJobController < ApplicationController
  def start_job
    message_broker = DisqueJockey::Broker.new
    message_broker.publish('test_queue', 'my_job', 1000)
  end
end
````

Congrats, you're now set up to publish and consume from Disque in your rails app!




##Roadmap:
DisqueJockey is not a currently a production-ready system, and there are a number of goals for it that have not been met yet.
Here is a list of functionality I'd like to add to DisqueJockey in the near future:
- Allow workers to set auto-acknowledge or fast-acknowledge of messages.
- Better test coverage around worker groups
- Rails integration (ActiveJob Adapter)
- More use cases in the README (e.g. how to use alongside Rails)
