image_path = Rails.root.join("app/assets/images")

User.create!(
  username: "Example User",
  email: "example@railstutorial.org",
  password: "foobar",
  password_confirmation: "foobar",
  admin: true,
  phone: Faker::Number.leading_zero_number(digits: 10)
)

10.times do |n|
  User.create!(
    username: Faker::Name.name,
    email: "example-#{n + 1}@gmail.com",
    password: "password",
    password_confirmation: "password",
    phone: Faker::Number.leading_zero_number(digits: 10)
  )
end

room_types = [
  { name: "Deluxe", description: "Phòng cao cấp với view biển", price: 150000.0, view: "Sea", images: ["sheraton_1.jpg", "sheraton_2.jpg"] },
  { name: "Standard", description: "Phòng tiêu chuẩn, tiện nghi đầy đủ", price: 100000.0, view: "City", images: ["sheraton_3.jpg", "sheraton_4.jpg"] },
  { name: "Suite", description: "Phòng hạng sang với không gian rộng rãi", price: 200000.0, view: "Garden", images: ["standard_room.jpg", "super_vip.jpg"] }
]

room_types.each do |room_type|
  images = room_type.delete(:images)
  rt = RoomType.create!(room_type)

  images.each do |image_name|
    image_file = image_path.join(image_name)
    if File.exist?(image_file)
      rt.images.attach(
        io: File.open(image_file),
        filename: image_name,
        content_type: "image/jpeg"
      )
    end
  end

  3.times do |i|
    Room.create!(
      room_type: rt,
      room_number: "#{rt.name[0..2]}-#{i + 1}",
      floor: (i % 5) + 1
    )
  end
end

3.times do |n|
  Request.create!(
    checkin_date: Date.today,
    checkout_date: Date.today + 3,
    user: User.find(n + 2),
    status: 1,
    room_type: RoomType.find(n + 1),
    quantity: 2
  )
end

10.times do |n|
  Service.create!(
    name: "Service #{n + 1}",
    price: (n + 1) * 10000
  )
end

10.times do |n|
  Review.create!(
    user: User.find((n % 10) + 1),
    score: rand(1..5),
    content: Faker::Lorem.sentence(word_count: 10)
  )
end
