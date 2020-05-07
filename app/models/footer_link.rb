class FooterLink < ApplicationRecord
	enum link_type: { sparestaff_section: 0, easy_online_recruitment_section: 1, employee_sharing_hiring_section: 2 }
	belongs_to :static_content, optional: true
end
