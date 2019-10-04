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
