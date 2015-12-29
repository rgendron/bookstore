FactoryGirl.define do
  sequence :name do |n|
    "Format #{n}"
  end

  factory :book_format_type do
    name
    physical true

    trait :physical do
      physical true
    end

    trait :electronic do
      physical false
    end
  end
end
