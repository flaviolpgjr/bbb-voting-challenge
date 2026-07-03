FactoryBot.define do
  factory :vote do
    wall { nil }
    participant { nil }
    ip_address { "MyString" }
    user_agent { "MyString" }
  end
end
