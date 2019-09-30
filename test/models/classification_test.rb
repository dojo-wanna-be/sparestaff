# == Schema Information
#
# Table name: classifications
#
#  id                       :bigint           not null, primary key
#  parent_classification_id :integer
#  name                     :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

require 'test_helper'

class ClassificationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
