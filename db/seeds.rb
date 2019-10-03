# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if Classification.count < 1
  c1 = Classification.create(name: 'Accounting')
  c1.sub_classifications.create(name: 'Accounts Officers/Clerks')
  c1.sub_classifications.create(name: 'Accounts Payable')
  c1.sub_classifications.create(name: 'Accounts Receivable/Credit Control')
  c1.sub_classifications.create(name: 'Analysis & Reporting')
  c1.sub_classifications.create(name: 'Assistant Accountants')

  c2 = Classification.create(name: 'Administration & Office Support')
  c2.sub_classifications.create(name: 'Accounts Officers/Clerks')
  c2.sub_classifications.create(name: 'Accounts Payable')
  c2.sub_classifications.create(name: 'Accounts Receivable/Credit Control')

  c3 = Classification.create(name: 'Advertising, Arts & Media')
  c3.sub_classifications.create(name: 'Accounts Payable')
  c3.sub_classifications.create(name: 'Accounts Receivable/Credit Control')
  c3.sub_classifications.create(name: 'Assistant Accountants')

  c4 = Classification.create(name: 'Banking & Financial Services')
  c4.sub_classifications.create(name: 'Accounts Officers/Clerks')
  
  c5 = Classification.create(name: 'Information & Communication Technology')
  c5.sub_classifications.create(name: 'Accounts Officers/Clerks')
  c5.sub_classifications.create(name: 'Accounts Payable')
  c5.sub_classifications.create(name: 'Accounts Receivable/Credit Control')
  c5.sub_classifications.create(name: 'Analysis & Reporting')
end

if Language.count < 1
  ["English", "Korean", "Chinese-mandarin", "Russian",
  "Chinese-cantonese", "German", "Spanish", "Portugese",
  "Arabic", "Turkish", "Hindi", "Thai", "French",
  "Vietnamese", "Dutch", "Burmese", "Italian",
  "Indonesian", "Japanese"].each do |l|
    Language.create(language: l.titleize)
  end
end
