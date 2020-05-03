class EmployeeHireSection < ApplicationRecord
	has_attached_file :column_1_image, styles: { medium: "300x300", thumb: "100x100" }
  validates_attachment_content_type :column_1_image, content_type: /\Aimage\/.*\Z/
  validates_attachment_file_name :column_1_image, matches: [/png\Z/, /jpe?g\Z/]

  has_attached_file :column_2_image, styles: { medium: "300x300", thumb: "100x100" }
  validates_attachment_content_type :column_2_image, content_type: /\Aimage\/.*\Z/
  validates_attachment_file_name :column_2_image, matches: [/png\Z/, /jpe?g\Z/]

  has_attached_file :column_3_image, styles: { medium: "300x300", thumb: "100x100" }
  validates_attachment_content_type :column_3_image, content_type: /\Aimage\/.*\Z/
  validates_attachment_file_name :column_3_image, matches: [/png\Z/, /jpe?g\Z/]

  has_attached_file :column_4_image, styles: { medium: "300x300", thumb: "100x100" }
  validates_attachment_content_type :column_4_image, content_type: /\Aimage\/.*\Z/
  validates_attachment_file_name :column_4_image, matches: [/png\Z/, /jpe?g\Z/]
end
