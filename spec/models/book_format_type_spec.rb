require 'rails_helper'

RSpec.describe BookFormatType, type: :model do

  describe "associations" do
    it { should have_many(:book_formats) }
  end

  describe "validations" do
    subject { BookFormatType.new(physical: false) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should allow_values(true,false).for(:physical) }
  end

  describe "scopes" do
    before(:each) do
      create_list(:book_format_type, 3, :physical)
      create_list(:book_format_type, 2, :electronic)
    end

    describe ".physical" do
      it 'should return only physical format types' do
        expect(BookFormatType.physical.all?(&:physical?)).to be true
      end

      it 'should return all physical format types' do
        expect(BookFormatType.physical.count).to eq 3
      end
    end

    describe '.electronic' do
      it 'should return only electronic format types' do
        expect(BookFormatType.electronic.all?(&:electronic?)).to be true
      end

      it 'should return all electronic format types' do
        expect(BookFormatType.electronic.count).to eq 2
      end
    end
  end

  describe "#to_s" do
    it "should be the right string" do
      expect(subject.to_s).to eq subject.name
    end
  end

  describe "#electronic?" do
    let(:physical) { create :book_format_type, :physical }
    let(:electronic) { create :book_format_type, :electronic }

    it "should return true for electronic books" do
      expect(electronic.electronic?).to be true
    end

    it "should return false for physical books" do
      expect(physical.electronic?).to be false
    end
  end
end
