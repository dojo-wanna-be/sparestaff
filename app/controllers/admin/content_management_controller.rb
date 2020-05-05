class Admin::ContentManagementController < Admin::AdminBaseController
  
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
  end
end