class EmployeeListingsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_listing, only: [:new_listing_step_2,
                                      :create_listing_step_2,
                                      :new_listing_step_3,
                                      :create_listing_step_3,
                                      :new_listing_step_4,
                                      :add_relevant_document,
                                      :add_profile_picture,
                                      :add_verification_front,
                                      :add_verification_back,
                                      :create_listing_step_4,
                                      :new_listing_step_5,
                                      :create_listing_step_5,
                                      :preview_listing,
                                      :publish_listing,
                                      :show,
                                      :edit,
                                      :update,
                                      :listing_deactivation]

  before_action :find_company, only: [:create_listing_step_2]

  def getting_started
  end

  def index
    # if current_user.is_owner? || current_user.is_hr?
    #   @employee_listings = current_user.company.employee_listings
    # elsif current_user.is_individual?
    #   @employee_listing = current_user.employee_listings
    # end
    company_listings = current_user.company.present? && current_user.company.employee_listings.present? ? current_user.company.employee_listings : []
    individual_listings = current_user.employee_listings.present? ? current_user.employee_listings : []

    @employee_listings = company_listings + individual_listings
    @employee_listings = @employee_listings.sort_by{|e| e[:updated_at]}.reverse
  end

  def new_listing_step_1
    if params[:back].eql?("true")
      find_listing
      @employee_listing.destroy
    end
    # unless params[:back].eql?("true")
    #   if current_user.is_owner? || current_user.is_hr?
    #     @employee_listing = current_user.company.employee_listings.build
    #     @employee_listing.listing_step = 1
    #     if @employee_listing.save
    #       redirect_to step_2_employee_path(id: @employee_listing.id)
    #     else
    #       flash[:error] = @employee_listing.errors.full_messages.to_sentence
    #     end
    #   elsif current_user.is_individual?
    #     @employee_listing = current_user.employee_listings.first
    #     redirect_to step_3_employee_path(id: @employee_listing.id)
    #   end
    # else
    #   current_user.employee_listings.destroy_all if current_user.is_individual?
    #   current_user.company.employee_listings.destroy_all if current_user.is_owner? || current_user.is_hr?
    #   current_user.company.destroy if current_user.is_owner? || current_user.is_hr?
    #   current_user.update_attribute(:user_type, nil)
    # end
  end

  def create_listing_step_1
    if params[:poster_type].eql?("individual")
      @employee_listing = current_user.employee_listings.build
      @employee_listing.listing_step = 1
      if @employee_listing.save
        redirect_to step_3_employee_path(id: @employee_listing.id)
      else
        flash[:error] = @employee_listing.errors.full_messages.to_sentence
        redirect_to step_1_employee_index_path(id: @employee_listing.id)
      end
    elsif params[:poster_type].eql?("company")
      if current_user.company.present?
        company = current_user.company
      else
        company = Company.new
      end
      if company.save
        current_user.company_id = company.id
        current_user.save
        @employee_listing = company.employee_listings.build
        @employee_listing.listing_step = 1
        if @employee_listing.save
          redirect_to step_2_employee_path(id: @employee_listing.id)
        else
          flash[:error] = "Listing not processed because #{@employee_listing.errors.full_messages.to_sentence}"
          redirect_to step_1_employee_index_path(id: @employee_listing.id)
        end
      else
        flash[:error] = "Company not saved because #{company.errors.full_messages.to_sentence}"
        redirect_to step_1_employee_index_path(id: @employee_listing.id)
      end
    else
      flash[:error] = "Invalid Choice"
      redirect_to step_1_employee_index_path(id: @employee_listing.id)
    end
  end

  def new_listing_step_2
    unless params[:back].eql?("true")
      if @employee_listing.listing_step >= 1
        if @employee_listing.lister_type.eql?("Company")
          @company = @employee_listing.lister
        else
          flash[:error] = "You can't go to this step"
          redirect_to step_3_employee_path(id: @employee_listing.id)
        end
      else
        flash[:error] = "You can't go to this step"
        redirect_to step_1_employee_index_path(id: @employee_listing.id)
      end
    else
      if @employee_listing.lister_type.eql?("Company")
        @company = @employee_listing.lister
      else
        redirect_to step_1_employee_index_path(id: @employee_listing.id, back: true)
      end
    end
  end

  def create_listing_step_2
    @company.update(company_params)
    current_user.update_attribute(:user_type, params[:user_role].to_i)
    @employee_listing.update_attribute(:listing_step, 2)
    if params[:save_later]
      redirect_to employee_index_path
    else
      redirect_to step_3_employee_path(id: @employee_listing.id)
    end
  end

  def new_listing_step_3
    unless (((@employee_listing.lister_type.eql?("User") && @employee_listing.listing_step >= 1) || @employee_listing.listing_step >= 2) && params[:back].eql?("true")) || (@employee_listing.lister_type.eql?("User") && @employee_listing.listing_step >= 1) || @employee_listing.listing_step >= 2
      flash[:error] = "You can't go to this step"
      redirect_to step_1_employee_index_path(id: @employee_listing.id)
    end
  end

  def create_listing_step_3
    @employee_listing.update(listing_params)
    @employee_listing.update_attribute(:listing_step, 3)
    if params[:save_later]
      redirect_to employee_index_path
    else
      redirect_to step_4_employee_path(id: @employee_listing.id)
    end
  end

  def new_listing_step_4
    unless (params[:back].eql?("true") && @employee_listing.listing_step >= 3) || @employee_listing.listing_step >= 3
      flash[:error] = "You can't go to this step"
      redirect_to "/employee/#{@employee_listing.id}/step_#{@employee_listing.listing_step}"
    end
    classification = @employee_listing.classification
    if classification.present? 
      @classification_id = classification.classification.id
      @sub_classification_id = classification.id
    end
  end

  def create_listing_step_4
    if params[:employee_skills].present?
      @employee_listing.employee_skills.destroy_all
      params[:employee_skills].split(',').each do |skill|
        EmployeeSkill.create(skill_name: skill, employee_listing_id: @employee_listing.id)
      end
    end
    @employee_listing.update(listing_skill_params)
    @employee_listing.update_attribute(:classification_id, params[:classification_id])
    if params[:employee_listing_language_ids].present?
      @employee_listing.employee_listing_languages.destroy_all
      params[:employee_listing_language_ids].each do |language_id|
        EmployeeListingLanguage.create(employee_listing_id: @employee_listing.id, language_id: language_id)
      end
    end
    # if params[:employee_listing][:relevant_documents].present?
    #   @employee_listing.relevant_documents.destroy_all
    #   @employee_listing.relevant_documents.attach(params[:employee_listing][:relevant_documents])
    # end
    @employee_listing.update_attribute(:listing_step, 4)
    if params[:save_later]
      redirect_to employee_index_path
    else
      redirect_to step_5_employee_path(id: @employee_listing.id)
    end
  end

  def new_listing_step_5
    unless (params[:back].eql?("true") && @employee_listing.listing_step >= 4) || @employee_listing.listing_step >= 4
      flash[:error] = "You can't go to this step"
      redirect_to "/employee/#{@employee_listing.id}/step_#{@employee_listing.listing_step}"
    end
  end

  def create_listing_step_5
    @employee_listing.update(listing_availability_params)

    if params[:slot_ids].present?
      @employee_listing.employee_listing_slots.destroy_all
      params[:slot_ids].each do |slot_id|
        EmployeeListingSlot.create(employee_listing_id: @employee_listing.id, slot_id: slot_id)
      end
    end

    @employee_listing.listing_availabilities.destroy_all
    ListingAvailability::DAYS.map{|k,v| v}.each do |day|
      ListingAvailability.create(employee_listing_id: @employee_listing.id,
                                  day: day,
                                  start_time: params[:start_time].present? ? params[:start_time].first[:"#{day}"] : "",
                                  end_time: params[:end_time].present? ? params[:end_time].first[:"#{day}"] : "",
                                  not_available: params[:unavailable_days].present? ? params[:unavailable_days].include?(day) : false)
    end

    @employee_listing.update_attribute(:listing_step, 5)
    if params[:save_later]
      redirect_to employee_index_path
    else
      redirect_to preview_employee_path(id: @employee_listing.id)
    end
  end

  def preview_listing
    unless @employee_listing.listing_step >= 5
      flash[:error] = "You can't go to this step"
      redirect_to "/employee/#{@employee_listing.id}/step_#{@employee_listing.listing_step}"
    end
  end

  def publish_listing
    if request.get?
      unless @employee_listing.listing_step >= 5 && @employee_listing.published.eql?(true)
        flash[:error] = "You can't go to this step"
        if @employee_listing.listing_step < 6
          redirect_to "/employee/#{@employee_listing.id}/step_#{@employee_listing.listing_step}"
        else
          redirect_to preview_employee_path(id: @employee_listing.id)
        end
      end
    elsif request.patch?
      if params[:published].eql?("true")
        @employee_listing.update_attributes(published: true, listing_step: 6)
      elsif params[:save_later]
        @employee_listing.update_attribute(:listing_step, 6)
        redirect_to employee_index_path
      end
      if @employee_listing.published?
        user_admin = User.where(is_admin: true)
        if user_admin.present?
          UserMailer.admin_listing_confirmation(user_admin).deliver!
        end

        if @employee_listing.tfn.blank? || (@employee_listing.verification_front_image.blank? && @employee_listing.verification_back_image.blank?)
          UserMailer.tfn_and_photo_verification(current_user, @employee_listing).deliver!
        end

        UserMailer.listing_create_confirmation(current_user).deliver!
      end
    end
  end

  def show
  end

  def edit
    classification = @employee_listing.classification
    if classification.present? 
      @classification_id = classification.classification.id
      @sub_classification_id = classification.id
    end
  end

  def update
    if params[:edit].eql?("employee_skills")
      @employee_listing.update_attribute(:classification_id, params[:classification_id]) if params[:classification_id].present?
      
      if params[:employee_skills].present?
        @employee_listing.employee_skills.destroy_all
        params[:employee_skills].split(',').each do |skill|
          EmployeeSkill.create(skill_name: skill, employee_listing_id: @employee_listing.id)
        end
      end

      if params[:employee_listing_language_ids].present?
        @employee_listing.employee_listing_languages.destroy_all
        params[:employee_listing_language_ids].each do |language_id|
          EmployeeListingLanguage.create(employee_listing_id: @employee_listing.id, language_id: language_id)
        end
      end
    end

    if params[:edit].eql?("listing_availability")
      if params[:slot_ids].present?
        @employee_listing.employee_listing_slots.destroy_all
        params[:slot_ids].each do |slot_id|
          EmployeeListingSlot.create(employee_listing_id: @employee_listing.id, slot_id: slot_id)
        end
      end

      @employee_listing.listing_availabilities.destroy_all
      ListingAvailability::DAYS.map{|k,v| v}.each do |day|
        ListingAvailability.create(employee_listing_id: @employee_listing.id,
                                    day: day,
                                    start_time: params[:start_time].present? ? params[:start_time].first[:"#{day}"] : "",
                                    end_time: params[:end_time].present? ? params[:end_time].first[:"#{day}"] : "",
                                    not_available: params[:unavailable_days].present? ? params[:unavailable_days].include?(day) : false)
      end
    end

    if @employee_listing.update_attributes(update_listing_params)
      flash[:notice] = "Updated Successfully"
      if params[:redirect_link].present?
        redirect_to edit_employee_path(id: @employee_listing.id, edit: params[:redirect_link])
      else
        redirect_to edit_employee_path(id: @employee_listing.id, edit: params[:edit])
      end
    else
      flash[:error] = @employee_listing.errors.full_messages.to_sentence
      redirect_to edit_employee_path(id: @employee_listing.id, edit: params[:edit])
    end
  end

  def sub_category_lists
    # @classification = Classification.find(params[:id])
  end

  def add_relevant_document
    if params[:relevant_document_id]
      @employee_listing.relevant_documents.find(params[:relevant_document_id]).destroy
    else
      relevant_document =  Paperclip.io_adapters.for(params[:image])
      document = @employee_listing.relevant_documents.new
      document.document = relevant_document

      @status = if document.save
        true 
      else
        false
      end
    end
  end

  def add_profile_picture
    if params[:type]
      @employee_listing.profile_picture = nil
    else
      profile_picture =  Paperclip.io_adapters.for(params[:image])
      @employee_listing.profile_picture = profile_picture
    end

    @status = if @employee_listing.save
      true 
    else
      false
    end
  end

  def add_verification_front
    if params[:type]
      @employee_listing.verification_front_image = nil
    else
      verification_front =  Paperclip.io_adapters.for(params[:image])
      @employee_listing.verification_front_image = verification_front
    end

    @status = if @employee_listing.save
      true 
    else
      false
    end
  end

  def add_verification_back
    if params[:type]
      @employee_listing.verification_back_image = nil
    else
      verification_back =  Paperclip.io_adapters.for(params[:image])
      @employee_listing.verification_back_image = verification_back
    end

    @status = if @employee_listing.save
      true 
    else
      false
    end
  end

  def listing_deactivation
    if params[:edit].eql?("deactivation_feedback")
      if @employee_listing.update_attribute(:deactivation_reason, params[:employee_listing][:deactivation_reason])
        flash[:notice] = "Reason Submitted Successfully"
        redirect_to edit_employee_path(id: @employee_listing.id, edit: params[:edit])
      else
        flash[:error] = @employee_listing.errors.full_messages.to_sentence
        redirect_to edit_employee_path(id: @employee_listing, edit: "listing_status")
      end
    elsif params[:edit].eql?("deactivation_done")
      if @employee_listing.update_attributes(deactivation_feedback: params[:employee_listing][:deactivation_feedback], deactivated: true)
        flash[:notice] = "Listing Deactivated Successfully"
        redirect_to deactivated_employee_index_path
      else
        flash[:error] = @employee_listing.errors.full_messages.to_sentence
        redirect_to edit_employee_path(id: @employee_listing, edit: "listing_status")
      end
    end
  end

  def deactivated_completely
  end

  private

  def company_params
    params.require(:company).permit(
      :name,
      :acn,
      :address_1,
      :address_2,
      :city,
      :state,
      :post_code,
      :country,
      :contact_no
    )
  end

  def listing_params
    params.require(:employee_listing).permit(
      :title,
      :first_name,
      :last_name,
      :tfn,
      :birth_year,
      :address_1,
      :address_2,
      :city,
      :state,
      :country,
      :post_code,
      :residency_status,
      :other_residency_status,
      :verification_type,
      :gender,
      :has_vehicle
    )
  end

  def listing_skill_params
    params.require(:employee_listing).permit(
      :skill_description,
      :optional_comments
    )
  end

  def listing_availability_params
    params[:employee_listing][:weekday_price] = params[:employee_listing][:other_weekday_price] if params[:employee_listing][:other_weekday_price].present?
    params[:employee_listing][:weekend_price] = params[:employee_listing][:other_weekend_price] if params[:employee_listing][:other_weekend_price].present?
    params[:employee_listing][:holiday_price] = params[:employee_listing][:other_holiday_price] if params[:employee_listing][:other_holiday_price].present?
    params.require(:employee_listing).permit(
      :available_in_holidays,
      :weekday_price,
      :weekend_price,
      :holiday_price,
      :minimum_working_hours,
      :start_publish_date,
      :end_publish_date
    )
  end

  def update_listing_params
    params[:employee_listing][:weekday_price] = params[:employee_listing][:other_weekday_price] if params[:employee_listing][:other_weekday_price].present?
    params[:employee_listing][:weekend_price] = params[:employee_listing][:other_weekend_price] if params[:employee_listing][:other_weekend_price].present?
    params[:employee_listing][:holiday_price] = params[:employee_listing][:other_holiday_price] if params[:employee_listing][:other_holiday_price].present?
    params.require(:employee_listing).permit(
      :title,
      :first_name,
      :last_name,
      :tfn,
      :birth_year,
      :address_1,
      :address_2,
      :city,
      :state,
      :country,
      :post_code,
      :residency_status,
      :other_residency_status,
      :verification_type,
      :gender,
      :has_vehicle,
      :verification_front_image,
      :verification_back_image,
      :skill_description,
      :optional_comments,
      :profile_picture,
      :available_in_holidays,
      :weekday_price,
      :weekend_price,
      :holiday_price,
      :minimum_working_hours,
      :start_publish_date,
      :end_publish_date
    )
  end

  def find_listing
    @employee_listing = EmployeeListing.find(params[:id])
    rescue Exception
      flash[:error] = "Couldn't find the Record"
      redirect_to employee_index_path
  end

  def find_company
    @company = Company.find(params[:company_id])
  end

end
