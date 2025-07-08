FactoryBot.define do
    factory :review do
      user
      score { Settings.reviews_score }
      content { Settings.reviews_content}
    end
  end
