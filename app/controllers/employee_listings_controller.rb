class EmployeeListingsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_listing, only: [:new_listing_step_2,
                                      :create_listing_step_2,
                                      :new_listing_step_3,
                                      :create_listing_step_3,
                                      :new_listing_step_4,
                                      :create_listing_step_4,
                                      :new_listing_step_5,
                                      :create_listing_step_5,
                                      :preview_listing,
                                      :publish_listing,
                                      :show]

  before_action :find_company, only: [:create_listing_step_2]

  def getting_started
  end

  def index
    if current_user.is_owner? || current_user.is_hr?
      @employee_listings = current_user.company.employee_listings.where(published: true)
    elsif current_user.is_individual?
      @employee_listing = current_user.employee_listings.where(published: true)
    end
  end

  def new_listing_step_1
    if current_user.is_owner? || current_user.is_hr?
      @employee_listing = current_user.company.employee_listings.build
      if @employee_listing.save
        redirect_to employee_step_2_path(id: @employee_listing.id)
      else
        flash[:error] = @employee_listing.errors.full_messages.to_sentence
      end
    elsif current_user.is_individual?
      @employee_listing = current_user.employee_listings.first
      redirect_to employee_step_3_path(id: @employee_listing.id)
    end
  end

  def create_listing_step_1
    if params[:poster_type].eql?("individual")
      @employee_listing = current_user.employee_listings.build
      @employee_listing.listing_step = 1
      if @employee_listing.save
        redirect_to employee_step_3_path(id: @employee_listing.id)
      else
        flash[:error] = @employee_listing.errors.full_messages.to_sentence
        redirect_to employee_step_1_path(id: @employee_listing.id)
      end
    elsif params[:poster_type].eql?("company")
      company = Company.new
      if company.save
        current_user.company_id = company.id
        current_user.save
        @employee_listing = company.employee_listings.build
        @employee_listing.listing_step = 1
        if @employee_listing.save
          redirect_to employee_step_2_path(id: @employee_listing.id)
        else
          flash[:error] = "Listing not processed because #{@employee_listing.errors.full_messages.to_sentence}"
          redirect_to employee_step_1_path(id: @employee_listing.id)
        end
      else
        flash[:error] = "Company not saved because #{company.errors.full_messages.to_sentence}"
        redirect_to employee_step_1_path(id: @employee_listing.id)
      end
    else
      flash[:error] = "Invalid Choice"
      redirect_to employee_step_1_path
    end
  end

  def new_listing_step_2
    if @employee_listing.listing_step >= 1
      if @employee_listing.lister_type.eql?("Company")
        @company = @employee_listing.lister
      else
        flash[:error] = "You can't go to this step"
        redirect_to employee_step_3_path(id: @employee_listing.id)
      end
    else
      flash[:error] = "You can't go to this step"
      redirect_to employee_step_1_path(id: @employee_listing.id)
    end
  end

  def create_listing_step_2
    @company.update(company_params)
    current_user.update_attribute(:user_type, params[:user_role].to_i)
    @employee_listing.update_attribute(:listing_step, 2)
    redirect_to employee_step_3_path(id: @employee_listing.id)
  end

  def new_listing_step_3
    unless (@employee_listing.lister_type.eql?("User") && @employee_listing.listing_step >= 1) || @employee_listing.listing_step >= 2
      flash[:error] = "You can't go to this step"
      redirect_to employee_step_1_path(id: @employee_listing.id)
    end
  end

  def create_listing_step_3
    @employee_listing.update(listing_params)
    @employee_listing.verification_front_image.attach(params[:employee_listing][:verification_front_image])
    @employee_listing.verification_back_image.attach(params[:employee_listing][:verification_back_image])
    @employee_listing.update_attribute(:listing_step, 3)
    redirect_to employee_step_4_path(id: @employee_listing.id)
  end

  def new_listing_step_4
    unless @employee_listing.listing_step >= 3
      flash[:error] = "You can't go to this step"
      redirect_to "/employee/step_#{@employee_listing.listing_step}?id=#{@employee_listing.id}"
    end
  end

  def create_listing_step_4
    @employee_listing.update(listing_skill_params)
    @employee_listing.update_attributes(classification_id: params[:classification_id])
      if params[:employee_listing_language_ids].present?
        @employee_listing.employee_listing_languages.destroy_all
        params[:employee_listing_language_ids].each do |language_id|
        EmployeeListingLanguage.create(employee_listing_id: @employee_listing.id, language_id: language_id)
        if  @employee_listing.relevant_documents.present?
          @employee_listing.relevant_documents.attach(params[:employee_listing][:relevant_documents])
        end
      end
    end
    @employee_listing.update_attribute(:listing_step, 4)
    redirect_to employee_step_5_path(id: @employee_listing.id)
  end

  def new_listing_step_5
    unless @employee_listing.listing_step >= 4
      flash[:error] = "You can't go to this step"
      redirect_to "/employee/step_#{@employee_listing.listing_step}?id=#{@employee_listing.id}"
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

    if params[:unavailable_days].present?
      @employee_listing.listing_availabilities.destroy_all
      (ListingAvailability::DAYS.map{|k,v| v} - params[:unavailable_days]).each do |day|
        ListingAvailability.create(employee_listing_id: @employee_listing.id,
                                    day: day,
                                    start_time: params[:start_time].first[:"#{day}"],
                                    end_time: params[:end_time].first[:"#{day}"])
      end
    else
      @employee_listing.listing_availabilities.destroy_all
      ListingAvailability::DAYS.map{|k,v| v}.each do |day|
        ListingAvailability.create(employee_listing_id: @employee_listing.id,
                                    day: day,
                                    start_time: params[:start_time].first[:"#{day}"],
                                    end_time: params[:end_time].first[:"#{day}"])
      end
    end

    @employee_listing.update_attribute(:listing_step, 5)
    redirect_to employee_preview_path(id: @employee_listing.id)
  end

  def preview_listing
    unless @employee_listing.listing_step >= 5
      flash[:error] = "You can't go to this step"
      redirect_to "/employee/step_#{@employee_listing.listing_step}?id=#{@employee_listing.id}"
    end
  end

  def publish_listing
    unless @employee_listing.listing_step >= 5
      flash[:error] = "You can't go to this step"
      redirect_to "/employee/step_#{@employee_listing.listing_step}?id=#{@employee_listing.id}"
    else
      @employee_listing.update_attributes(published: true, listing_step: 6) if params[:published].eql?("true")
      if @employee_listing.published?
        user_admin = User.where(is_admin: true)
        if user_admin.present?
          UserMailer.admin_listing_confirmation(user_admin).deliver!
        end

        if @employee_listing.tfn.blank?
         UserMailer.tfn_verification(current_user).deliver!
        end

        UserMailer.listing_create_confirmation(current_user).deliver!
        UserMailer.photo_verification(current_user).deliver!
      end
    end
  end

  def show
  end

  def sub_category_lists
    # @classification = Classification.find(params[:id])
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
    params[:employee_listing][:holiday_price] = params[:employee_listing][:other_holiday_price] if params[:employee_listing][:other_holiday_price].present?
    params.require(:employee_listing).permit(
      :available_in_holidays,
      :weekday_price,
      :holiday_price,
      :minimum_working_hours,
      :start_publish_date,
      :end_publish_date
    )
  end

  def find_listing
    @employee_listing = EmployeeListing.find(params[:id])
  end

  def find_company
    @company = Company.find(params[:company_id])
  end

end
