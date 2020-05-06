class HomepageContent < ApplicationRecord
	has_attached_file :content_image, styles: { medium: "300x300", thumb: "100x100" }
  validates_attachment_content_type :content_image, content_type: /\Aimage\/.*\Z/
  validates_attachment_file_name :content_image, matches: [/png\Z/, /jpe?g\Z/]
	belongs_to :static_content, foreign_key: "static_content_id"
	enum section_type: { employee_hiring_section: 0, how_it_work_section: 1 }
end
