# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Classification.import_csv("public/classification.csv")

if Language.count < 1
  ["English", "Korean", "Chinese-mandarin", "Russian",
  "Chinese-cantonese", "German", "Spanish", "Portugese",
  "Arabic", "Turkish", "Hindi", "Thai", "French",
  "Vietnamese", "Dutch", "Burmese", "Italian",
  "Indonesian", "Japanese"].each do |l|
    Language.create(language: l.titleize)
  end
end

if Slot.count < 1
  ["Full time", "Part time", "Casual"].each do |slot|
    Slot.create(time_slot: slot)
  end
end

if TaxDetail.count < 1
  t1 = TaxDetail.create(weekly_earning: 355 , a: 0 , b: 0)
  t2 = TaxDetail.create(weekly_earning: 422 , a: 0.1900 , b: 67.4635)
  t3 = TaxDetail.create(weekly_earning: 528 , a: 0.2900 , b: 109.7321)
  t4 = TaxDetail.create(weekly_earning: 711 , a: 0.2100 , b: 67.4635)
  t5 = TaxDetail.create(weekly_earning: 1282 , a: 0.3477 , b: 165.4423)
  t6 = TaxDetail.create(weekly_earning: 1730 , a: 0.3450 , b: 161.9808)
  t7 = TaxDetail.create(weekly_earning: 3461 , a: 0.4700 , b: 239.8654)
end
