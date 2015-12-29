FactoryGirl.define do
  factory :book do
    title "Secrets of the JavaScript Ninja, Second Edition"
    publisher
    author

    trait :with_reviews do
      transient do
        ratings [3]
      end

      after(:create) do |instance, evaluator|
        evaluator.ratings.map { |r| create(:book_review, book: instance, rating: r) }
      end
    end

    trait :with_physical_formats do
      transient do
        physical_count 1
      end
      after(:create) do |instance, evaluator|
        create_list :book_format, evaluator.physical_count, :physical, book: instance
      end
    end

    trait :with_electronic_formats do
      transient do
        electronic_count 1
      end
      after(:create) do |instance, evaluator|
        create_list :book_format, evaluator.electronic_count, :electronic, book: instance
      end
    end
  end
end
