# function_object
[![Build Status](https://travis-ci.org/marshall-lee/function_object.svg?branch=master)](https://travis-ci.org/marshall-lee/function_object)

`FunctionObject` solves a problem of complex² callable¹ objects.

1. By *callable* I mean something that `respond_to? :call`. `lambda` and `proc` in Ruby are examples of callable objects.
2. By *complex* I mean something that requires sub-expressions. In other words, *complex* is when you need to express your `call` method in terms of other (private) methods. In other words, *complex* is when you need `def` inside your lambda or/and need to extract it to separate unit. *(So, the explanation of what is complex gone complex too :)*

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'function_object'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install function_object

## Usage

```ruby
class Plus < FunctionObject
  args do
    arg :a
    arg :b
  end

  def call
    a + b
  end
end

Plus.call(1,2) # => 3
Plus.(1,2) # => 3

plus = Plus.new(1,2) # => #<Plus:0x00000002115e48 @a=1, @b=2>
plus.(1,2) # => 3
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marshall-lee/function_object.

