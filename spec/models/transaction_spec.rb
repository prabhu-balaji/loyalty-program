require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe "testing model methods" do
    before(:all) do
      @customer = FactoryBot.create(:customer)
    end

    it "should throw validation error for transaction without customer_id" do
      transaction = Transaction.new(external_id: "random", amount: 33.0)
      expect(transaction.valid?).to be false
      expect(transaction.errors.full_messages.first).to eql("Customer must exist")
    end

    it "should throw validation error for transaction without amount" do
      transaction = Transaction.new(external_id: "random", customer_id: @customer.id)
      expect(transaction.valid?).to be false
      expect(transaction.errors.full_messages.first).to eql("Amount can't be blank")
    end

    it "should create transaction with amount and prefill transaction date & region_type" do
      amount = 2
      transaction = Transaction.create(external_id: KSUID.new.to_s, amount: amount, customer_id: @customer.id)
      expect(transaction.id.present?).to be true
      expect(transaction.gid.starts_with?('txn_')).to be true
      expect(transaction.transaction_date.to_s).to eql(transaction.created_at.to_s)
      expect(transaction.region_type).to eql(Transaction::REGION_TYPE[:domestic])
      expect(transaction.amount.to_f).to eql(amount.to_f)
    end

    it "should create a transaction with fields" do
      external_id = KSUID.new.to_s
      amount = 5555.4434
      transaction_date = "2021-09-23T08:33:57+00:00"
      transaction = Transaction.create(external_id: external_id, amount: amount, transaction_date: transaction_date,
                                       region_type: Transaction::REGION_TYPE[:domestic], customer_id: @customer.id)
      expect(transaction.id.present?).to be true
      expect(transaction.gid.starts_with?('txn_')).to be true
      expect(AppHelperMethods.standardize_datetime(transaction.transaction_date)).to eql(transaction_date.to_datetime.utc.in_time_zone.to_time.iso8601)
      expect(transaction.external_id).to eql(external_id)
      expect(transaction.amount.to_f).to eql(amount.to_f)
      expect(transaction.created_at.present?).to be true
      expect(transaction.updated_at.present?).to be true
      expect(transaction.region_type).to eql(Transaction::REGION_TYPE[:domestic])
      expect(transaction.customer).to eql(@customer)
    end

    it "should create a foreign based transaction" do
      external_id = KSUID.new.to_s
      amount = 200
      transaction_date = "2020-09-23T08:33:57+08:00"
      transaction = Transaction.create(external_id: external_id, amount: amount, transaction_date: transaction_date,
                                       region_type: Transaction::REGION_TYPE[:foreign], customer_id: @customer.id)
      expect(transaction.id.present?).to be true
      expect(transaction.gid.starts_with?('txn_')).to be true
      expect(AppHelperMethods.standardize_datetime(transaction.transaction_date)).to eql(transaction_date.to_datetime.utc.in_time_zone.to_time.iso8601)
      expect(transaction.external_id).to eql(external_id)
      expect(transaction.amount.to_f).to eql(amount.to_f)
      expect(transaction.region_type).to eql(Transaction::REGION_TYPE[:foreign])
      expect(transaction.created_at.present?).to be true
      expect(transaction.updated_at.present?).to be true
      expect(transaction.customer).to eql(@customer)
    end

    it "should throw error when trying to create a transaction with external id already present" do
      transaction = FactoryBot.create(:transaction)
      expect(transaction.id.present?).to be true
      duplicate_transaction = Transaction.new(external_id: transaction.external_id, amount: 4,
                                              customer_id: @customer.id)
      expect { duplicate_transaction.save }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "testing points evaluation on transaction create" do
    before(:all) do
      @customer = FactoryBot.create(:customer)
    end

    before(:each) do
      @customer.reload
    end

    it "should test points for txn < $100" do
      customer_points = @customer.points
      transaction = @customer.transactions.create(amount: 80, region_type: Transaction::REGION_TYPE[:domestic])
      expect(transaction.customer_points_entry).to be nil
      expect(@customer.points).to eql(customer_points)
    end

    it "should test points addition for domestic txn = $100" do
      initial_customer_points = @customer.points
      transaction = @customer.transactions.create(amount: 100, region_type: Transaction::REGION_TYPE[:domestic])
      @customer.reload
      expect(transaction.customer_points_entry.present?).to be true
      expect(transaction.customer_points_entry.customer_id).to eql(@customer.id)
      expect(transaction.customer_points_entry.points).to eql(10)
      expect(@customer.points).to eql(initial_customer_points + 10)
    end

    it "should test points addition for domestic txn > $100" do
      initial_customer_points = @customer.points
      transaction = @customer.transactions.create(amount: 780, region_type: Transaction::REGION_TYPE[:domestic])
      @customer.reload
      expect(transaction.customer_points_entry.present?).to be true
      expect(transaction.customer_points_entry.customer_id).to eql(@customer.id)
      expect(transaction.customer_points_entry.points).to eql(70)
      expect(@customer.points).to eql(initial_customer_points + 70)
    end

    it "should test points addition for foreign txn > $100" do
      initial_customer_points = @customer.points
      transaction = @customer.transactions.create(amount: 780, region_type: Transaction::REGION_TYPE[:foreign])
      @customer.reload
      expect(transaction.customer_points_entry.present?).to be true
      expect(transaction.customer_points_entry.customer_id).to eql(@customer.id)
      expect(transaction.customer_points_entry.points).to eql(140)
      expect(@customer.points).to eql(initial_customer_points + 140)
      latest_customer_points = @customer.points

      # should not add points when txn is updated. not a valid usecase as of now, but better to verify.
      transaction.external_id = KSUID.new.to_s
      transaction.save
      expect(@customer.reload.points).to eql(latest_customer_points)
    end
  end
end
