# frozen_string_literal: true

require "spec_helper"

RSpec.describe Lockless::Model do
  let(:uuid_regex) { /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ }
  it "has a version number" do
    expect(Lockless::VERSION).not_to be nil
  end

  context "with User model with custom lockless_column" do
    with_model :User, scope: :all do
      table do |t|
        t.string :name
        t.string :custon_uuid, default: "lockless", null: false
        t.timestamps null: false
      end

      model do
        include Lockless::Model
        self.lockless_column = :custon_uuid
      end
    end

    let(:user) { User.new }

    describe "before_save" do
      it "updates custon_uuid with standard .save" do
        expect(user.custon_uuid).to eq("lockless")
        user.save!
        expect(user.custon_uuid).to match(uuid_regex)
      end
    end
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

    describe "before_save" do
      it "updates lockless_uuid with standard .save" do
        expect(user.lockless_uuid).to eq("lockless")
        user.save!
        expect(user.lockless_uuid).to match(uuid_regex)
      end
    end

    describe "#lockless_save" do
      context "with new record" do
        it "updates lockless_uuid" do
          expect(user.lockless_uuid).to eq("lockless")
          expect(user.lockless_save).to eq(true)
          expect(user.lockless_uuid).to match(uuid_regex)
          expect(user).to_not be_new_record
        end

        context "with invalid user" do
          before(:each) do
            allow(user).to receive(:valid?).and_return(false)
          end

          it "updates lockless_uuid" do
            expect { user.lockless_save! }.to raise_error(ActiveRecord::RecordInvalid)
          end
        end
      end

      context "with saved record" do
        let!(:user) { User.create(name: "Initial Name") }
        let(:user2) { User.find(user.id) }

        it "invalidates when all are updated" do
          user.name = "name1"
          initial_lockless_uuid = user.lockless_uuid

          User.where(id: user.id).update_all(name: "new name")

          expect(user.lockless_save!).to eq(false)
          expect(user.reload.lockless_uuid).to_not eq(initial_lockless_uuid)
        end

        it "only updates first record updated" do
          user.name = "name1"
          user2.name = "name2"
          expect(user2.lockless_save!).to eq(true)
          expect(user.lockless_save!).to eq(false)
          expect(user.reload.name).to eq("name2")
        end
      end
    end
  end
end
