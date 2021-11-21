# Lockless

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/lockless`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lockless'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install lockless

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/lockless. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/lockless/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Lockless project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/lockless/blob/master/CODE_OF_CONDUCT.md).









```sh
bundle exec rails g migration AddLocklessUuidTo<ModelName> lockless_uuid:string
````

Update migration to add default + null: false

```ruby
  def change
    add_column :TABLE_NAME, :lockless_uuid, :string, default: "lockless", null: false
  end
```





```ruby


  before_save :set_lockless_uuid
  after_save :after_saving

  def log_attributes_changed
    changed_attrs = {}
    self.changed_attributes.each do |prop, old_value|
      changed_attrs[prop.to_sym] = {
        from: old_value,
        to: self[prop]
      }
    end
    Rails.logger.info "changed_attributes: #{changed_attrs.to_json}"
  end

  def after_saving
    puts "after_saving..."
  end

  def set_lockless_uuid
    old_lockless_uuid = self.lockless_uuid
    self.lockless_uuid = SecureRandom.uuid
    puts "set_lockless_uuid: '#{old_lockless_uuid}' -> '#{self.lockless_uuid}'"
  end

  def lockless_save
    return false unless self.valid?
    old_lockless_uuid = self.lockless_uuid

    self.run_callbacks(:save) do |variable|
      new_attrs = Hash[self.changed.collect { |prop| [prop.to_sym, self[prop]] }]
      self.log_attributes_changed

      update_count = self.class.where(id: self.id, lockless_uuid: old_lockless_uuid).update_all(new_attrs)
      if update_count == 1
        self.changes_applied
        true
      else
        self.lockless_uuid = old_lockless_uuid
        false
      end
    end
  end

  def lockless_save!
    self.validate!
    self.lockless_save
  end

```
