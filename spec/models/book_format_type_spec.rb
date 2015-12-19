require 'rails_helper'

RSpec.describe BookFormatType, type: :model do

  describe "associations" do
    it { should have_many(:book_formats) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should allow_values(true,false).for(:physical) }
  end


  describe "scopes" do
    before(:each) do
      create(:book_format_type, name: "Physical 1", physical: true)
      create(:book_format_type, name: "Physical 2", physical: true)
      create(:book_format_type, name: "Physical 3", physical: true)
      create(:book_format_type, name: "Electronic 1", physical: false)
      create(:book_format_type, name: "Electronic 2", physical: false)
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
      format_type = create(:book_format_type)
      expect(format_type.to_s).to eq format_type.name
    end
  end

  describe "#electronic?" do
    let(:physical) { BookFormatType.create(name: "Physical", physical: true) }
    let(:electronic) { BookFormatType.create(name: "Electronic", physical: false) }

    it "should return true for electronic books" do
      expect(electronic.electronic?).to be true
    end

    it "should return false for physical books" do
      expect(physical.electronic?).to be false
    end
  end
end
