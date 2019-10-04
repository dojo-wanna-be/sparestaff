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
  require 'csv'
  
  has_many :sub_classifications, class_name: "Classification", foreign_key: "parent_classification_id", dependent: :destroy
  belongs_to :classification, class_name: "Classification", foreign_key: "parent_classification_id", optional: true
  validates :name, :presence => true
  has_many :employee_listings

  def self.import_csv(file)
    CSV.foreach(file, headers: true) do |row|
      classification = find_by_id(row["id"]) || new
      classification.attributes = classification_params(row)
      classification.save!
    end
  end

  def self.classification_params(row)
    {
      id: row["id"],
      parent_classification_id: row["parent_classification_id"].eql?("NULL") ? nil : row["parent_classification_id"],
      name: row["name"]
    }
  end
end
