FactoryGirl.define do
  sequence :first_name do |n|
    "John #{n}"
  end

  factory :author do
    first_name { generate :first_name }
    last_name "Resig"
  end

end
