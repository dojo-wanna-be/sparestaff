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
    (friendliness_grade(listing_id) + knowledge_n_skills_grade(listing_id) + punctuality_grade(listing_id) + management_skill_grade(listing_id) + professionalism_grade(listing_id) + communication_grade(listing_id))/6
  end

  def friendliness_grade(listing_id)
    listing_all_reviews(listing_id).sum(:friendliness_grade)/listing_all_reviews(listing_id).count > 0 ? listing_all_reviews(listing_id).sum(:friendliness_grade)/listing_all_reviews(listing_id).count : 0
  end

  def knowledge_n_skills_grade(listing_id)
    knowledge_n_skills_grade = listing_all_reviews(listing_id).sum(:knowledge_n_skills_grade)/listing_all_reviews(listing_id).count > 0 ? listing_all_reviews(listing_id).sum(:knowledge_n_skills_grade)/listing_all_reviews(listing_id).count : 0
  end

  def punctuality_grade(listing_id)
    punctuality_grade = listing_all_reviews(listing_id).sum(:punctuality_grade)/listing_all_reviews(listing_id).count > 0 ? listing_all_reviews(listing_id).sum(:punctuality_grade)/listing_all_reviews(listing_id).count : 0
  end

  def management_skill_grade(listing_id)
    management_skill_grade = listing_all_reviews(listing_id).sum(:management_skill_grade)/listing_all_reviews(listing_id).count > 0 ? listing_all_reviews(listing_id).sum(:management_skill_grade)/listing_all_reviews(listing_id).count : 0
  end

  def professionalism_grade(listing_id)
    professionalism_grade = listing_all_reviews(listing_id).sum(:professionalism_grade)/listing_all_reviews(listing_id).count > 0 ? listing_all_reviews(listing_id).sum(:professionalism_grade)/listing_all_reviews(listing_id).count : 0
  end

  def communication_grade(listing_id)
    communication_grade = listing_all_reviews(listing_id).sum(:communication_grade)/listing_all_reviews(listing_id).count > 0 ? listing_all_reviews(listing_id).sum(:communication_grade)/listing_all_reviews(listing_id).count : 0
  end

  def listing_all_reviews(listing_id)
    Review.where(listing_id: listing_id).where.not(friendliness_grade: nil,knowledge_n_skills_grade: nil,punctuality_grade: nil,management_skill_grade: nil, professionalism_grade: nil, communication_grade: nil)
  end

  def hirer_commission
    ((CommunityServiceFee.last&.commission_from_hirer).to_f/100).round(2)
  end

  def poster_commission
    ((CommunityServiceFee.last&.commission_from_poster).to_f/100).round(2)
  end

  def discount_amount(tx, amount)
    if tx.discount_coupon.present?
      discount = amount * tx.discount_percent/100
      (amount - discount).round(2)
    else
      amount.round(2)
    end
  end
end
