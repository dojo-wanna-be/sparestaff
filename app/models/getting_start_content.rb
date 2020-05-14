class GettingStartContent < ApplicationRecord
	has_attached_file :cover_image
  validates_attachment_content_type :cover_image, content_type: /\Aimage\/.*\z/
	has_many :homepage_contents, foreign_key: "getting_start_content_id", dependent: :destroy
	has_many :frequently_ask_questions, foreign_key: "getting_start_content_id", dependent: :destroy
  accepts_nested_attributes_for :homepage_contents, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :frequently_ask_questions, reject_if: :all_blank, allow_destroy: true
end
