FactoryBot.define do
    factory :service do
      name { Faker::Commerce.product_name.truncate(Settings.services.name_max_length) }
      price { Faker::Commerce.price(range: Settings.zero + 1..Settings.max_price_value - 1) }
  
      after(:build) do |service|
        service.image.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/default-thumbnail.jpg")),
          filename: "default-thumbnail.jpg",
          content_type: "image/jpeg"
        )
      end
    end
  end
