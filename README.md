# CronHelper

The Cron Helper gem is designed to add a few additional features to cron jobs created with the [Whenever](https://github.com/javan/whenever) gem.

Why use Cron Helper?

- *Overlapping job prevention*: File based locking to prevent jobs from running if they are already running.  This is especially useful if - job takes longer than it should (such as an hourly cron that happens to take two hours to run).
- *Controlled concurrency*: Use tasks to limit concurrency and use jobs to encourage it.
- *Exception handling*: An exception in one task won't cause other tasks to fail.
- *Productivity*: Make it easier to add new fetures to a job without having to think about scheduling.
- *Logging*: Handle job and task output however you want.  This includes exceptions.

## Installation

First make sure you install the Whenever gem and verify that it's working.
Then add this line to your application's Gemfile:

```ruby
gem 'cron_helper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cron_helper

## Usage

#### Jobs

For your typical Rails or Ruby app, you will first want to create your ````ApplicationCronJob````.
This is the class that all of your custom jobs should inherit from.
Here you put methods that are shared by all your custom jobs.

```ruby
class ApplicationCronJob < CronHelper::Job
end
```

Next you will create your app specific job classes.
The idea is to pick logical names that relate to how they are going to be scheduled and grouped.
Inside of each class you will register your tasks.

Think of tasks as methods with exception protection and ordering.
Tasks are guaranteed to run in the order you register them.
They are also guaranteed to run even if a previous task encountered an exception.

```ruby
class HourlyJob < ApplicationCronJob
  register :do_some_work
  register :do_some_other_work
  register :do_even_more_work

  private

  def do_some_work
    raise 'I am a task that breaks quite often.'
  end

  def do_some_other_work
    puts 'I am a task that loves to talk.'
    STDERR.puts 'I even like to talk about errors.'
  end

  def do_even_more_work
    # I am a silent champion of a task.
  end
end
```

#### Scheduling

Finally you will schedule your jobs using the [Whenever](https://github.com/javan/whenever) gem.
Below is an example config/schedule.rb that also forces your jobs to run at a low priority.
Running jobs at a low priority is recommended when your server has other roles (web, app, db, etc).

```ruby
job_type :runner,  "cd :path && nice -n 20 bundle exec rails runner -e :environment ':task' :output"

every 1.hour do
  runner('HourlyJob.new.run')
end
```

#### Customization
You can customize where stdout/stderr are sent to by overriding the ````output_handler```` method.
Normally you will want to put this in ```ApplicationJob```.

```ruby
class ApplicationJob < CronHelper::Job
  private

  def output_handler(output)
    return unless output.length > 0

    # Print all output to STDOUT similar to how any other crontab entry would.
    puts output

    # Send only output with production exceptions to the rollbar.com service.
    if Rails.env.production? && output =~ /EXCEPTION/
      Rollbar.error("cron_helper exception (#{job_name})", output: output)
    end
  end
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cron_helper.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

