class Admin::EmployeeListingsController < Admin::AdminBaseController
  
  include EmployeeListingsHelper
  include ApplicationHelper
  
  before_action :find_listing, only: [:delete_or_pause_listing, :edit, :update, :show, :listing_deactivation]

  def index
    if params[:search_fields].present? && search_fields
      if pause_listing_search_field
        @listings = delete_pause_listings
      elsif params[:selected_data] == "200"
        @listings = listings.paginate(:page => params[:page], :per_page => 200)
      elsif params[:selected_data] == "100"
        @listings = listings.paginate(:page => params[:page], :per_page => 100)
      else
        @listings = listings.paginate(:page => params[:page], :per_page => 50)
      end
      @listings = listings.paginate(:page => params[:page], :per_page => params[:selected_data].present? ? params[:selected_data].to_i : 50)
    elsif params[:delete_pause_listings].present? && pause_listing_search_field
      @listings = delete_pause_listings
    else
      @listings = EmployeeListing.active.published.delete_status.paginate(:page => params[:page], :per_page => 50)
    end
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
        redirect_to edit_admin_employee_listing_path(id: @employee_listing.id, edit: params[:redirect_link])
      else
        redirect_to edit_admin_employee_listing_path(id: @employee_listing.id, edit: params[:edit])
      end
    else
      flash[:error] = @employee_listing.errors.full_messages.to_sentence
      redirect_to edit_admin_employee_listing_path(id: @employee_listing.id, edit: params[:edit])
    end
  end

  def listing_deactivation
    if params[:edit].eql?("deactivation_feedback")
      if @employee_listing.update_attribute(:deactivation_reason, params[:employee_listing][:deactivation_reason])
        flash[:notice] = "Reason Submitted Successfully"
        redirect_to edit_admin_employee_listing_path(id: @employee_listing.id, edit: params[:edit])
      else
        flash[:error] = @employee_listing.errors.full_messages.to_sentence
        redirect_to edit_admin_employee_listing_path(id: @employee_listing, edit: "listing_status")
      end
    elsif params[:edit].eql?("deactivation_done")
      if @employee_listing.update_attributes(deactivation_feedback: params[:employee_listing][:deactivation_feedback], deactivated: true)
        flash[:notice] = "Listing Deactivated Successfully"
        redirect_to deactivated_admin_employee_listings_path
      else
        flash[:error] = @employee_listing.errors.full_messages.to_sentence
        redirect_to edit_admin_employee_listing_path(id: @employee_listing, edit: "listing_status")
      end
    end
  end


  def deactivated_completely
  end


  def delete_or_pause_listing
    if params[:check_type].eql?("delete_listing")
      @status = params[:checked] == "true" ? "Delete" : "Active"
      @employee_listing.update_attributes(deleted_at: params[:checked], status: @status)
    else
      @status = params[:checked] == "true" ? "Pause" : "Active"
      @employee_listing.update_attributes(pause_at: params[:checked], status: @status)
    end
  end

  
  def upload_csv
    @emp_listings = EmployeeListing.active.published
    respond_to do |format|
      format.html
      format.csv { send_data @emp_listings.to_csv, filename: "emp_listing_record-#{Date.today}.csv" }
    end
  end

 private
  
  def listings
    data = {}
    data[:created_at_gteq] = params[:created_at_gteq] if params[:created_at_gteq].present?
    data[:created_at_lteq] = params[:created_at_lteq] if params[:created_at_lteq].present?
    
    listing = EmployeeListing.active.published.delete_status.ransack(first_name_or_last_name_cont_any: params[:q].split().first, lister_of_User_type_first_name_or_last_name_eq: params[:q].split().first, employee_skills_skill_name_or_title_cont_any: params[:q], id_in: params[:q],  m: 'or').result(distinct: true)
    @listing = listing.ransack(data, m: 'or').result(distinct: true)

  end
  
  

  def delete_pause_listings
    if params[:data_show] == "Pause Listings"
      listings = EmployeeListing.active.published.pause_listing.paginate(:page => params[:page], :per_page => 50) 
    end
  end

  def pause_listing_search_field
    result = (params[:data_show] == "Pause Listings")
  end
  
  def search_fields
    result = (params[:q].present? || params[:created_at_gteq].present? || params[:created_at_lteq].present?)
  end

  def find_listing
    @employee_listing = EmployeeListing.find_by(id: params[:id])
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

end
