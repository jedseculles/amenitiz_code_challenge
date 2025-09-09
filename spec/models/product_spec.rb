require 'rails_helper'

RSpec.describe Product, type: :model do
  # These tests assume the schema defined in db/schema.rb
  # Products have: code (unique, presence), name (presence), base_price (presence, > 0), active (boolean)

  describe 'database columns' do
    # Basic smoke checks to ensure table columns exist as expected
    it 'has expected columns' do
      expect(described_class.column_names).to include('code', 'name', 'base_price', 'active')
    end
  end

  describe 'validations' do
    # Minimal validations to guard data integrity for the catalog
    subject { described_class.new(code: 'GR1', name: 'Green Tea', base_price: 3.11) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    it 'requires code' do
      subject.code = nil
      expect(subject).to be_invalid
      expect(subject.errors[:code]).to be_present
    end

    it 'requires name' do
      subject.name = nil
      expect(subject).to be_invalid
      expect(subject.errors[:name]).to be_present
    end

    it 'requires base_price' do
      subject.base_price = nil
      expect(subject).to be_invalid
      expect(subject.errors[:base_price]).to be_present
    end
  end

  describe 'scopes' do
    # Active scope is useful to filter product catalog
    it 'filters by active true' do
      active_product = Product.create!(code: 'A1', name: 'Active', base_price: 1.00, active: true)
      _inactive_product = Product.create!(code: 'I1', name: 'Inactive', base_price: 1.00, active: false)

      expect(Product.where(active: true)).to include(active_product)
    end
  end
end


