class HomepageContent < ApplicationRecord
	has_attached_file :content_image
	validates_attachment_content_type :content_image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
	validates_attachment_file_name :content_image, matches: [/png\Z/, /jpe?g\Z/]
	enum section_type: { employee_hiring_section: 0, how_it_work_section: 1, getting_started_employee_hiring_section: 2, getting_started_how_it_work_section: 3, safety_on_spare_staff: 4 }
	belongs_to :getting_start_content, optional: true
	belongs_to :static_content, foreign_key: "static_content_id"
end
