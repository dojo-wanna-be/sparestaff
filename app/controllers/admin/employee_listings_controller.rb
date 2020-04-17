class Admin::EmployeeListingsController < Admin::AdminBaseController
  include EmployeeListingsHelper
  include ApplicationHelper

  def index
    @listings = EmployeeListing.all
    # if current_user.is_owner? || current_user.is_hr?
    #   @employee_listings = current_user.company.employee_listings
    # elsif current_user.is_individual?
    #   @employee_listing = current_user.employee_listings
    # end
  end
end