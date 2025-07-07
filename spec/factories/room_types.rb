FactoryBot.define do
    factory :room_type do
      name { "Standard Room" }
      description { "A cozy room" }
      price { 100 }
    end
  end

  FactoryBot.define do
    factory :room do
      room_type
      room_number { "101" }
      floor { 1 }
    end
  end
