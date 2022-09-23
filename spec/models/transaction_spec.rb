require 'rails_helper'

RSpec.describe Transaction, type: :model do
  it "should throw validation error for transaction without amount" do
    transaction = Transaction.new(external_id: "random")
    expect(transaction.valid?).to be false
    expect(transaction.errors.full_messages.first).to eql("Amount can't be blank")
  end

  it "should create transaction with amount and prefill transaction date & region_type" do
    amount = 2
    transaction = Transaction.create(external_id: KSUID.new.to_s, amount: amount)
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
                                     region_type: Transaction::REGION_TYPE[:domestic])
    expect(transaction.id.present?).to be true
    expect(transaction.gid.starts_with?('txn_')).to be true
    expect(AppHelperMethods.standardize_datetime(transaction.transaction_date)).to eql(transaction_date.to_datetime.utc.in_time_zone.to_time.iso8601)
    expect(transaction.external_id).to eql(external_id)
    expect(transaction.amount.to_f).to eql(amount.to_f)
    expect(transaction.created_at.present?).to be true
    expect(transaction.updated_at.present?).to be true
    expect(transaction.region_type).to eql(Transaction::REGION_TYPE[:domestic])
  end

  it "should create a foreign based transaction" do
    external_id = KSUID.new.to_s
    amount = 200
    transaction_date = "2020-09-23T08:33:57+08:00"
    transaction = Transaction.create(external_id: external_id, amount: amount, transaction_date: transaction_date,
                                     region_type: Transaction::REGION_TYPE[:foreign])
    expect(transaction.id.present?).to be true
    expect(transaction.gid.starts_with?('txn_')).to be true
    expect(AppHelperMethods.standardize_datetime(transaction.transaction_date)).to eql(transaction_date.to_datetime.utc.in_time_zone.to_time.iso8601)
    expect(transaction.external_id).to eql(external_id)
    expect(transaction.amount.to_f).to eql(amount.to_f)
    expect(transaction.region_type).to eql(Transaction::REGION_TYPE[:foreign])
    expect(transaction.created_at.present?).to be true
    expect(transaction.updated_at.present?).to be true
  end

  it "should throw error when trying to create a transaction with external id already present" do
    transaction = FactoryBot.create(:transaction)
    expect(transaction.id.present?).to be true
    duplicate_transaction = Transaction.new(external_id: transaction.external_id, amount: 4)
    expect { duplicate_transaction.save }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
