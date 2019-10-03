class EmployeeListingsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_listing, only: [:new_listing_step_2,
                                      :create_listing_step_2,
                                      :new_listing_step_3,
                                      :create_listing_step_3,
                                      :new_listing_step_4,
                                      :create_listing_step_4,
                                      :preview_listing,
                                      :publish_listing,
                                      :show]

  before_action :find_company, only: [:create_listing_step_2]

  def getting_started
  end

  def new_listing_step_1
    if current_user.is_owner? || current_user.is_hr?
      @employee_listing = current_user.company.employee_listings.build
      @employee_listing.save
      redirect_to employee_step_2_path(id: @employee_listing.id)
    elsif current_user.is_individual?
      @employee_listing = current_user.employee_listings.first
      redirect_to employee_step_3_path(id: @employee_listing.id)
    end
  end

  def create_listing_step_1
    if params[:poster_type].eql?("individual")
      @employee_listing = current_user.employee_listings.build
      @employee_listing.listing_step = 1
      @employee_listing.save
      redirect_to employee_step_3_path(id: @employee_listing.id)
    elsif params[:poster_type].eql?("company")
      company = Company.new
      company.save
      current_user.company_id = company.id
      current_user.save
      @employee_listing = company.employee_listings.build
      @employee_listing.listing_step = 1
      @employee_listing.save
      redirect_to employee_step_2_path(id: @employee_listing.id)
    else
      flash[:error] = "Invalid Choice"
      redirect_to employee_step_1_path
    end
  end

  def new_listing_step_2
    @company = @employee_listing.lister
  end

  def create_listing_step_2
    @company.update(company_params)
    current_user.update_attribute(:user_type, params[:user_role].to_i)
    @employee_listing.update_attribute(:listing_step, 2)
    redirect_to employee_step_3_path(id: @employee_listing.id)
  end

  def new_listing_step_3
  end

  def create_listing_step_3
    @employee_listing.update(listing_params)
    @employee_listing.update_attribute(:listing_step, 3)
    redirect_to employee_step_4_path(id: @employee_listing.id)
  end

  def new_listing_step_4
  end

  def create_listing_step_4
    @employee_listing.update(listing_skill_params)
    params[:employee_listing_language_ids].each do |language_id|
      EmployeeListingLanguage.create(employee_listing_id: @employee_listing.id, language_id: language_id)
    end
    @employee_listing.update_attribute(:listing_step, 4)
    redirect_to employee_preview_path(id: @employee_listing.id)
  end

  def preview_listing
  end

  def publish_listing
    @employee_listing.update_attributes(published: true, listing_step: 5) if params[:published].eql?("true")
    if @employee_listing.published.present?
      user = current_user
      user_admin = User.where(is_admin: true)
      if user_admin.present?
        UserMailer.admin_listing_confirmation(user_admin).deliver!
      end
      if @employee_listing.tfn.empty?
       UserMailer.tfn_verification(user).deliver!
      end
      UserMailer.listing_create_confirmation(user).deliver!
      UserMailer.photo_verification(user).deliver!
    end
  end

  def show
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
      :classification_id,
      :skill_description,
      :optional_comments
    )
  end

  def find_listing
    @employee_listing = EmployeeListing.find(params[:id])
  end

  def find_company
    @company = Company.find(params[:company_id])
  end
end
