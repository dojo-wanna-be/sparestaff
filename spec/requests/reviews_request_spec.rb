require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do

  before(:each) do
    @poster = FactoryGirl.create(:user, email: "poster123@gmail.com")
  	@hirer =  FactoryGirl.create(:user, email: "sparestaffhirer@gmail.com")
    @hirer.confirmed_at = Time.zone.now
    @hirer.save
    sign_in @hirer
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
    @booking = FactoryGirl.create(:booking, transaction_id: @transaction.id)
  end

  describe "GET new" do

	  it "has a 200 status code" do
	    get :new, params: {tx_id: @transaction.id}
	    expect(response.success?).to eq(true)
    	expect(response.status).to eq(200)
    end
  end

   describe "GET index" do

	  it "has a 200 status code" do
	    get :index
	    expect(response.success?).to eq(true)
    	expect(response.status).to eq(200)
    end
  end

  describe "POST create/:id" do

	  it "has a 200 status code" do
	    post :create, params: {review: {transaction_id: @transaction.id, sender_id: @poster.id, receiver_id: @hirer.id, listing_id: @employee_listing.id, public_feedback: "", private_feedback: "", work_environment_grade: nil, communication_grade: nil, employee_satisfaction_grade: nil, friendliness_grade: nil, punctuality_grade: nil, professionalism_grade: nil, knowledge_n_skills_grade: nil, management_skill_grade: nil, overall_experience: "Good", recommendation: "No Yet", spare_staff_experience: "" }}
      @review = Review.last
      if @review.present?
        get :step_2, params: {id: @review.id}
        if (response.status == 200) # ater step_2 it goes to update
          patch :update, params: {id: @review.id, review: {spare_staff_experience: "I my very happy with this client"} }

          #after successfully updatation it goes to last_step 
          get :last_step, params: {id: @review.transaction_id} if (response.status == 302)

          expect(response.success?).to eq(true)
          expect(response.status).to eq(200)
        end
      end
    end
  end
  
end