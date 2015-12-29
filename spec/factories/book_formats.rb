FactoryGirl.define do
  factory :book_format do
    book
    book_format_type

    trait :physical do
      book_format_type  { FactoryGirl.create(:book_format_type, :physical) }
    end

    trait :electronic do
      book_format_type  { FactoryGirl.create(:book_format_type, :electronic) }
    end

  end
end
