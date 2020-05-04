class HomepageContent < ApplicationRecord
	enum section_type: { employee_hiring_section: 0, how_it_work_section: 1 }
end
