FactoryGirl.define do
  sequence :publisher_name do |n|
    "Publisher #{n}"
  end
  factory :publisher do
    name { generate :publisher_name}
  end
end
