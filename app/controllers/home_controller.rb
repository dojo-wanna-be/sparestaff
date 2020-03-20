class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @user = User.new
    listings = EmployeeListing.active.published.order(updated_at: :desc)
    @employee_listings = listings.paginate(:page => params[:page], :per_page => 4)
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
    if params[:parent].present?
      if params[:parent].count > 1
        @classi_txt = "#{params[:parent].size} Classifications"
      else
        @classi_txt = Classification.where(id: params[:parent]).last.try(:name)
      end
    else
      @classi_txt = 'Any Classification'
    end
    @user = User.new
    q = {}
    q[:deactivated_eq] = false
    q[:published_eq] = true
    q[:classification_id_eq_any] = listing_ids
    q[:employee_skills_skill_name_or_title_cont_any] = params[:keyword_search]
    if params[:start_date].present? && params[:end_date].present?
      q[:start_publish_date_lteq] = params[:start_date].to_date
      q[:end_publish_date_gteq] = params[:end_date].to_date
    end
    q[:employee_listing_slots_slot_id_in] = params[:slot]
    if params[:minimum_rate].present? && params[:maximum_rate].present?
      q[:weekday_price_gteq] = params[:minimum_rate]
      q[:weekday_price_lteq] = params[:maximum_rate]
    elsif params[:minimum_rate].present?
      q[:weekday_price_gteq] = params[:minimum_rate]
    elsif params[:maximum_rate].present?
      q[:weekday_price_lteq] = params[:maximum_rate]
    end
    q[:residency_status_cont_any] = params[:residency_status]
    q[:gender_start_any] = params[:gender]
    q[:has_vehicle_in] = params[:has_vehicle]
    if params[:availability].present?
      a = params[:availability]
      a = a.map(&:to_i)
      q[:listing_availabilities_day_in] = a
      q[:listing_availabilities_not_available_eq] = false
    end
    q[:languages_language_start_any] = params[:language]

    min_year = Time.current.year - params[:minimun_age].to_i
    max_year = Time.current.year - params[:maximum_age].to_i
      if params[:minimun_age].present? && params[:maximum_age].present?
        q[:birth_year_lteq] = min_year
        q[:birth_year_gteq] = max_year
        q = {birth_year_lteq: 'min_year',birth_year_gteq: 'max_year'}
      elsif params[:minimun_age].present?
        q[:birth_year_lteq] = min_year
      elsif params[:maximum_age].present?
        q[:birth_year_gteq] = max_year
      end
    if params[:profile_picture].present?
      if params[:profile_picture][:photo_required].present?
        q[:profile_picture_file_name_not_eq] = nil
      elsif params[:profile_picture][:not_required].present?
        q[:profile_picture_file_name_eq] = nil
      end
    end
    # @listings = EmployeeListing.active.published.order(updated_at: :desc)
    # @listings = EmployeeListing.ransack(q).result(distinct: true)
    @employee_listings = EmployeeListing.includes(:employee_skills, :listing_availabilities, :employee_listing_slots, :languages).ransack(q).result(distinct: true)
    # @employee_listings = find_employee_listings(listings)
    @employee_listings = @employee_listings.near(params[:location])   if params[:location].present?
    @employee_listings = @employee_listings.order(updated_at: :desc).paginate(:page => params[:page], :per_page => 4)
    @classifications = Classification.includes(:sub_classifications).where(parent_classification_id: nil)
  end

  private
    # def find_employee_listings(listings)
    #   @listings = listings
    #   @listings = @listings.where(classification_id: listing_ids) if params[:parent].present?
    #   @listings = @listings.near(params[:location])   if params[:location].present?
    #   @listings = @listings.includes(:employee_skills).ransack(employee_skills_skill_name_cont_any: params[:keyword_search], title_cont_any: params[:keyword_search], m: 'or').result(distinct: true) if params[:keyword_search].present?
    #   @listings = @listings.ransack(start_publish_date_lteq: params[:start_date].to_date, end_publish_date_gteq: params[:end_date].to_date).result(distinct: true) if params[:start_date].present? && params[:end_date].present?
    #   @listings = @listings.includes(:employee_listing_slots).where(employee_listing_slots: {slot_id: params[:slot]}) if params[:slot].present?
    #   @listings = @listings.where("weekday_price >= ? OR weekend_price >= ? OR holiday_price >= ?", params[:minimum_rate], params[:minimum_rate], params[:minimum_rate]) if params[:minimum_rate].present?
    #   @listings = @listings.where("weekday_price <= ? OR weekend_price <= ? OR holiday_price <= ?", params[:maximum_rate], params[:maximum_rate], params[:maximum_rate]) if params[:maximum_rate].present?
    #   @listings = @listings.where(residency_status: params[:residency_status]) if params[:residency_status].present?
    #   @listings = @listings.where(gender: params[:gender]) if params[:gender].present?
    #   @listings = @listings.where(has_vehicle: params[:has_vehicle]) if params[:has_vehicle].present?
    #   @listings = @listings.includes(:listing_availabilities).where(listing_availabilities: {day: params[:availability]}) if params[:availability].present?
    #   @listings = @listings.includes(:languages).where(languages: {language: params[:language]}) if params[:language].present?

    #   if params[:minimun_age].present? && params[:maximum_age].present?
    #     min_year = Time.current.year - params[:minimun_age].to_i
    #     max_year = Time.current.year - params[:maximum_age].to_i
    #     @listings = @listings.where("birth_year between ? AND ?", min_year, max_year)
    #   elsif params[:minimun_age].present?
    #     min_year = Time.current.year - params[:minimun_age].to_i
    #     @listings = @listings.where("birth_year <= ?", min_year)
    #   elsif params[:maximum_age].present?
    #     max_year = Time.current.year - params[:maximum_age].to_i
    #     @listings = @listings.where("birth_year >= ?", max_year)
    #   end
    #   if(params[:profile_picture].present?)
    #     if params[:profile_picture][:photo_required].present? && params[:profile_picture][:not_required].present?
    #     elsif params[:profile_picture][:photo_required].present?
    #       @listings.where.not(profile_picture: nil)
    #     else
    #       @listings.where(profile_picture: nil)
    #     end
    #   end
    #   @listings
    # end

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
      else
        []
      end
    end

    def get_distance
    end
end
