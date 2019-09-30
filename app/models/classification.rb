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

class Classification < ApplicationRecord
  has_many :sub_classifications, class_name: "Classification", foreign_key: "parent_classification_id", dependent: :destroy
  belongs_to :classification, class_name: "Classification", foreign_key: "parent_classification_id", optional: true
  validates :name, :presence => true
  has_many :employee_listings
end
