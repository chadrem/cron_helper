# CronHelper

The Cron Helper gem is designed to add a few additional features to cron jobs created with the [https://github.com/javan/whenever](Whenever) gem.
This features include:
* File based locking to prevent a given cron from having duplicates running at the same time.
* Stdout and Stderr logging.
* The concept of "tasks" within a cron job (more on this below) for ordering and exception handling.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cron_helper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cron_helper

## Usage

For your typical Rails or Ruby app, you will first want to create your ApplicationJob.
This is the class that all of your custom crons should inherit from.

```ruby
class ApplicationJob < CronHelper::Job
end

Next you will create your app specific cron classes.
The idea is to pick logical names that relate to how they are going to be scheduled.
Inside of each app specific cron class you will register your tasks.

```ruby
class HourlyJob < ApplicationJob
  register :do_some_work
  register :do_some_other_work
  register :do_even_more_work

  private

  def do_some_work
    raise 'I break quite often'
  end

  def do_some_other_work
  end

  def do_even_more_work
    # I am a silent champion of a task.
  end
end

Finally you will schedule your jobs using the [https://github.com/javan/whenever](Whenever) gem.
Below is an example config/schedule.rb that also forces your jobs to run at a low priority.
Running crons at a low priority is recommended when your server has other roles (web, app, db, etc).

```ruby
job_type :runner,  "cd :path && nice -n 20 script/rails runner -e :environment ':task' :output"

every 1.hour do
  runner('Cron::Hourly.new.run')
end
end

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/cron_helper.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

