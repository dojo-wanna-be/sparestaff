module ApplicationHelper
  def listing_start_date(employee_listing)
    employee_listing.start_publish_date < Date.today ? Date.today : employee_listing.start_publish_date
  end

  def listing_end_date(employee_listing)
    employee_listing.end_publish_date
  end

  def listing_data
    default = [ ['Enter keywords', ''] ]
    default + EmployeeListing.all.pluck(:title, :id)
  end
end
