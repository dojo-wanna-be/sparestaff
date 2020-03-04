# == Schema Information
#
# Table name: relevant_documents
#
#  id                    :bigint           not null, primary key
#  document_content_type :string
#  document_file_name    :string
#  document_file_size    :bigint
#  document_updated_at   :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  employee_listing_id   :bigint
#
# Indexes
#
#  index_relevant_documents_on_employee_listing_id  (employee_listing_id)
#
# Foreign Keys
#
#  fk_rails_...  (employee_listing_id => employee_listings.id)
#

class RelevantDocument < ApplicationRecord
  belongs_to :employee_listing
  has_attached_file :document
  validates_attachment_content_type :document, content_type: /\Aimage\/.*\z/
end
