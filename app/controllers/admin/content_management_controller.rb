class Admin::ContentManagementController < Admin::AdminBaseController
<<<<<<< HEAD
	
	def design
		@static_content = StaticContent.last.present? ? StaticContent.last : StaticContent.new
		# @static_content.homepage_contents.build
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
		params.require(:static_content).permit(:site_logo, :employee_hiring_title, :how_it_work_title, homepage_contents_attributes: [:id, :section_type, :content_image, :content, :_destroy])
=======
  
  def design
  end

  def update_site_logo
    site_logo =  Paperclip.io_adapters.for(params[:site_logo])
    if StaticContent.last.present?
      static_content = StaticContent.last
      static_content.update(site_logo: site_logo)
      flash[:notice] = "Logo Updated successfully"
    else
      StaticContent.create(site_logo: site_logo)
      flash[:notice] = "Logo Created successfully!"
    end
    redirect_to design_admin_content_management_index_path
  end

  def employee_hiring_section
    @update = EmployeeHireSection.last
    if request.post?
      if @update
        @new_employee_hire_section = EmployeeHireSection.last
        @new_employee_hire_section.update(params[:employee_hire].permit!)
        flash[:success] = "Updated successfully"
      else
        @new_employee_hire_section = EmployeeHireSection.new(params[:employee_hire].permit!)
        if @new_employee_hire_section.save
          flash[:success] = "Updated successfully"
        else
          flash[:error] = "Something went wrong!"
        end
      end
      redirect_to employee_hiring_section_admin_content_management_index_path
    end
  end

  def how_it_works
  end

  def getting_started
    if request.get?
      @getting_started = GettingStartContent.new
      @getting_started.homepage_contents.build
      @getting_started.frequently_ask_questions.build
    else
      @getting_started = GettingStartContent.new(getting_start_content_params)
      @getting_started.save
    end
  end

  def getting_start_content_params
    params.require(:getting_start_content).permit(:cover_title, 
      :cover_subtitle,
      :button_title,
      :list_your_self_title,
      :how_it_works_title,
      :safety_title,
      :frequently_asked_title,
      :easy_online_title,
      :cover_image,homepage_content_attributes: [:content_image, :content, :section_type], frequently_ask_questions: [:section_type, :question, :answer])
>>>>>>> 43d38e5ae431d093b7f84e9737c87468f3cbb4c2
  end
end