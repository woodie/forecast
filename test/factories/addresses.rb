FactoryBot.define do
  factory :address do
    query { "truckee, ca" }
    place { create(:populated_place) }
  end
end
