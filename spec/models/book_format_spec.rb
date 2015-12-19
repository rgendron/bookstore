require 'rails_helper'

RSpec.describe BookFormat, type: :model do
  describe "associations" do
    it { should belong_to(:book) }
    it { should belong_to(:book_format_type) }
  end

  describe "validations" do
    it { should validate_presence_of(:book) }
    it { should validate_uniqueness_of(:book_id).scoped_to(:book_format_type_id) }
    it { should validate_presence_of(:book_format_type) }
  end
end
