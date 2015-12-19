require 'rails_helper'

RSpec.describe BookReview, type: :model do
  describe "associations" do
    it { should belong_to(:book) }
  end

  describe "validations" do
    it { should validate_presence_of(:book) }
    it { should validate_inclusion_of(:rating).in_range(1..5) }
  end
end
