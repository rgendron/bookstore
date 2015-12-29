require 'rails_helper'

RSpec.describe Author, type: :model do
  describe "associations" do
    it { should have_many(:books).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

    describe "#to_s" do
    it "returns the right string" do
      author = create(:author)
      expect(author.to_s).to eq "#{author.first_name} #{author.last_name}"
    end
  end
end
