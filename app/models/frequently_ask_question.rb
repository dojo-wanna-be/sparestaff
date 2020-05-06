class FrequentlyAskQuestion < ApplicationRecord
  belongs_to :getting_start_content, optional: true
  enum section_type: { getting_started: 0, earnings: 1 }
end
