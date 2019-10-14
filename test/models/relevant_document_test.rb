# == Schema Information
#
# Table name: relevant_documents
#
#  id                    :bigint           not null, primary key
#  employee_listing_id   :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :bigint
#  document_updated_at   :datetime
#

require 'test_helper'

class RelevantDocumentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
