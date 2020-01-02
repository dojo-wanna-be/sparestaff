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

  private
    def find_employee_listings(listings)
      @listings = listings
      @listings = @listings.where(classification_id: listing_ids) if params[:parent].present?
      @listings = @listings.near(params[:location])   if params[:location].present?
      @listings = @listings.includes(:employee_skills).ransack(employee_skills_skill_name_cont_any: params[:keyword_search], title_cont_any: params[:keyword_search], m: 'or').result(distinct: true) if params[:keyword_search].present?
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
