# frozen_string_literal: true

RSpec.describe Lockless do
  it "has a version number" do
    expect(Lockless::VERSION).not_to be nil
  end

  context "with simple User model" do
    with_model :User, scope: :all do
      table do |t|
        t.string :name
        t.string :lockless_uuid, default: "lockless", null: false
        t.timestamps null: false
      end

      model do
        include Lockless::Model
      end
    end

    let(:user) { User.new }

    it "gets updated with standard .save" do
      binding.pry
    end
  end
end
