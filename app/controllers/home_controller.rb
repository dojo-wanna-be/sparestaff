class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @user = User.new
    listings = EmployeeListing.active.published.order(updated_at: :desc)
    @employee_listings = find_employee_listings(listings)
    @employee_listings = @employee_listings.paginate(:page => params[:page], :per_page => 4)
    @classifications = Classification.includes(:sub_classifications).where(parent_classification_id: nil)
  end

  def email_availability
    email = User.pluck(:email).include?(params[:user][:email])
    if params[:form].eql?("signup")
      respond_to do |format|
        format.json { render :json => !email}
      end
    elsif params[:form].eql?("login")
      respond_to do |format|
        format.json { render :json => email}
      end
    end
  end

  def keyword_search
    @listings = EmployeeListing.active.published.includes(:employee_skills).ransack(employee_skills_skill_name_cont_any: params[:term], title_cont_any: params[:term], m: 'or').result(distinct: true)
    render json: @listings.pluck(:id, :title)
  end

  def search
    @user = User.new
    listings = EmployeeListing.active.published.order(updated_at: :desc)
    @employee_listings = find_employee_listings(listings)
    @employee_listings = @employee_listings.paginate(:page => params[:page], :per_page => 1)
    @classifications = Classification.includes(:sub_classifications).where(parent_classification_id: nil)
  end

  private
    def find_employee_listings(listings)
      @listings = listings
      @listings = @listings.where(classification_id: listing_ids) if params[:parent].present?
      @listings = @listings.near(params[:location])   if params[:location].present?
      @listings = @listings.includes(:employee_skills).ransack(employee_skills_skill_name_cont_any: params[:keyword_search], title_cont_any: params[:keyword_search], m: 'or').result(distinct: true) if params[:keyword_search].present?
      @listings = @listings.ransack(start_publish_date_lteq: params[:start_date].to_date, end_publish_date_gteq: params[:end_date].to_date).result(distinct: true) if params[:start_date].present? && params[:end_date].present?
      @listings = @listings.includes(:employee_listing_slots).where(employee_listing_slots: {slot_id: params[:slot]}) if params[:slot].present?
      @listings = @listings.where("weekday_price >= ? OR weekend_price >= ? OR holiday_price >= ?", params[:minimum_rate], params[:minimum_rate], params[:minimum_rate]) if params[:minimum_rate].present?
      @listings = @listings.where("weekday_price <= ? OR weekend_price <= ? OR holiday_price <= ?", params[:minimum_rate], params[:minimum_rate], params[:minimum_rate]) if params[:maximum_rate].present?
      @listings = @listings.where(residency_status: params[:residency_status]) if params[:residency_status].present?
      @listings = @listings.where(gender: params[:gender]) if params[:gender].present?
      @listings = @listings.where(has_vehicle: params[:has_vehicle]) if params[:has_vehicle].present?
      @listings = @listings.includes(:listing_availabilities).where(listing_availabilities: {day: params[:availability]}) if params[:availability].present?
      @listings = @listings.includes(:languages).where(languages: {language: params[:language]}) if params[:language].present?

      if params[:minimun_age].present? && params[:maximum_age].present?
        min_year = Time.current.year - params[:minimun_age]
        max_year = Time.current.year - params[:maximum_age]
        @listings = @listings.where("birth_year between ? AND ?", min_year, max_year)
      elsif params[:minimun_age].present?
        min_year = Time.current.year - params[:minimun_age]
        @listings = @listings.where("birth_year <= ?", min_year)
      elsif params[:maximum_age].present?
        max_year = Time.current.year - params[:maximum_age]
        @listings = @listings.where("birth_year >= ?", max_year)
      end
      if(params[:profile_picture].present?)
        if params[:profile_picture][:photo_required].present? && params[:profile_picture][:not_required].present?
        elsif params[:profile_picture][:photo_required].present?
          @listings.where.not(profile_picture: nil)
        else
          @listings.where(profile_picture: nil)
        end
      end
      @listings
    end

    def listing_ids
      if params[:parent].present?
        ids = []
        child_classification_id = params[:child].present? ? params[:child].map(&:to_i) : []
        params[:parent].each do |id|
          sub_classification_ids = Classification.find(id).sub_classifications.pluck(:id)
          if((sub_classification_ids & child_classification_id).empty?)
            ids << sub_classification_ids
          else
            ids << child_classification_id
          end
        end
        ids = ids.flatten
      end
    end

end
