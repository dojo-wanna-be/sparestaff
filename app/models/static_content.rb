class StaticContent < ApplicationRecord
	has_attached_file :site_logo, styles: { medium: "300x300", thumb: "100x100" }
  validates_attachment_content_type :site_logo, content_type: /\Aimage\/.*\Z/
  validates_attachment_file_name :site_logo, matches: [/png\Z/, /jpe?g\Z/]
  has_many	:homepage_contents
end
