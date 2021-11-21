# Lockless

[![Gem Version](https://badge.fury.io/rb/lockless.png)](https://badge.fury.io/rb/lockless)
[![CI Status](https://github.com/cianmce/lockless/actions/workflows/main.yml/badge.svg)](https://github.com/cianmce/lockless/actions)

Allows for safe concurrent updates to a single record without the need for locks.

This is done by only updating the record when the `lockless_uuid` is unchanged and updating the `lockless_uuid` with each update. Since the SQL update command is atomic we can scope the update to the old `lockless_uuid` and update it to a new value in a single update command.

## Installation

### Add gem

Add this line to your application's Gemfile:

```ruby
gem 'lockless'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install lockless

## Usage

### Classify model as "Lockless"

```ruby
class User < ActiveRecord::Base
  include Lockless::Model
end
```

### Migration to add lockless_uuid column

Manually add migration file or generate base with:

```sh
bundle exec rails g migration AddLocklessUuidTo<ModelName> lockless_uuid:string
# e.g.
bundle exec rails g migration AddLocklessUuidToUser lockless_uuid:string
````

Update migration to add default value and and make non-nullable

```ruby
class AddLocklessUuidToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :lockless_uuid, :string, default: "lockless", null: false
  end
end
```

### Sample Usage

```ruby
user1 = User.first # => #<User id: 1, ...>
user1.name = "new name1"

# other process
user2 = User.first # => #<User id: 1, ...>
user2.name = "new name2"

# Save user2 before saving user1
user2.lockless_save! # => true

# user1 fails to save as it's been updated earlier by user2
user1.lockless_save! # => false

# when lockless_save doesn't work you can either ignored the update
# or reload the record and try again

user1.reload
user1.name # => "new name2"
user1.name = "new name3"
user1.lockless_save! # => true
user1.reload.name # => "new name3"

user1.reload
user1.name = "new name1"
User.all.update_all(name: "new name4")

# user1 fails to save as it's been updated earlier in `update_all`
user1.lockless_save! # => false
user1.reload.name # => "new name4"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Testing
#### Run all specs + standardrb

```sh
bundle exec rake
```

#### Run only standardrb

```sh
bundle exec rake standard
````

#### Apply standardrb auto fixes

```sh
bundle exec rake standard:fix
```

#### Run specs using guard

```sh
bundle exec guard
```

This will auto run the related unit tests while you develop and save files.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lockless. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/lockless/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Lockless project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/lockless/blob/master/CODE_OF_CONDUCT.md).

## TODO

- [ ] Allow for custom primary key column name
- [ ] Allow a boolean to be passed to allow for validation to be skipped like in `.save`
