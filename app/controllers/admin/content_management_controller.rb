class Admin::ContentManagementController < Admin::AdminBaseController
	def design
		@static_content = StaticContent.last.present? ? StaticContent.last : StaticContent.new
		@static_content.homepage_contents.build
		@static_content.footer_links.build
		# @update = HomepageContent.last
	end

	def update
		@static_content = StaticContent.last.present? ? StaticContent.last : StaticContent.new
		if @static_content.update(content_params)
			flash[:notice] = "Content Updated successfully"
		end
		redirect_to design_admin_content_management_index_path
	end

	# def employee_hiring_section
	# 	@update = EmployeeHireSection.last
	# 	if request.post?
	# 		if @update
	# 			@new_employee_hire_section = EmployeeHireSection.last
	# 			@new_employee_hire_section.update(params[:employee_hire].permit!)
	# 			flash[:success] = "Updated successfully"
	# 		else
	# 			@new_employee_hire_section = EmployeeHireSection.new(params[:employee_hire].permit!)
	# 			if @new_employee_hire_section.save
	# 				flash[:success] = "Updated successfully"
	# 			else
	# 				flash[:error] = "Something went wrong!"
	# 			end
	# 		end
	# 		redirect_to employee_hiring_section_admin_content_management_index_path
	# 	end
	# end

	private

	def content_params
		params.require(:static_content).permit(:site_logo, :employee_hiring_title, :how_it_work_title, homepage_contents_attributes: [:id, :section_type, :content_image, :content, :_destroy], footer_links_attributes: [:id, :link_type, :link_name, :link_url, :_destroy])
  end
end