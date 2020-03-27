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

  def listing_star_rating(listing_id)
    reviews_all = listing_all_reviews(listing_id)
    friendliness_grade = reviews_all.sum(:friendliness_grade)/2
    knowledge_n_skills_grade = reviews_all.sum(:knowledge_n_skills_grade)/2
    punctuality_grade = reviews_all.sum(:punctuality_grade)/2
    management_skill_grade = reviews_all.sum(:management_skill_grade)/2
    professionalism_grade = reviews_all.sum(:professionalism_grade)/2
    communication_grade = reviews_all.sum(:communication_grade)/2
    friendliness_grade + knowledge_n_skills_grade + punctuality_grade + management_skill_grade + professionalism_grade + communication_grade
  end

  def listing_all_reviews(listing_id)
    reviews_all = Review.where(listing_id: listing_id)
  end
end
