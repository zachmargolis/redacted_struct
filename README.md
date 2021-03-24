# RedactedStruct

A version of Ruby's built-in Struct that redacts members when printing, and can allow specifying
members that can be printed normally (an allowlist).

```ruby
Config = RedactedStruct.new(
  :username,
  :password,
  :timeout,
  :url,
  keyword_init: true,
  allowed_members: [:username, :timeout]
)

config = Config.new(username: 'example', password: 'secret', timeout: 5, url: 'https://example.com')
=> #<struct Config username="example" password=[REDACTED] timeout=5>
```

## Pretty-Printing

The struct will automatically redact itself when pretty-printed via `#pp`:

```ruby
require 'pp'

pp config
#<struct Config
 username="example",
 password=[REDACTED],
 timeout=5,
 url="https://example.com">
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'redacted_struct'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install redacted_struct

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zachmargolis/redacted_struct.
