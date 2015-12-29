FactoryGirl.define do
  factory :book_review do
    book
    rating { rand(5) + 1 }
  end
end
