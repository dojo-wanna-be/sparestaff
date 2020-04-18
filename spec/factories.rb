FactoryGirl.define do

  factory :notification_setting do
  end
  factory :classification do
    id 413
    parent_classification_id 389
    name "Other"
    created_at DateTime.now
    updated_at DateTime.now
  end


  factory :review  do
     created_at Date.today
     updated_at Date.today
     public_feedback ""
     private_feedback ""
     work_environment_grade nil
     suitability_grade nil
     communication_grade nil
     employee_satisfaction_grade nil
     friendliness_grade nil
     punctuality_grade nil
     professionalism_grade nil
     knowledge_n_skills_grade nil
     management_skill_grade nil
     overall_experience "Terrible"
     recommendation "No"
     spare_staff_experience "not happy"
  end

  factory :listing_availability do
     start_time Date.today + 4.hours
     end_time Date.today + 10.hours
     day "sunday"
     created_at DateTime.now
     updated_at DateTime.now
     not_available false
  end


  factory :booking do
     day "friday"
     start_time Date.today
     end_time  3.months.from_now
     created_at DateTime.now
     updated_at DateTime.now
     booking_date Date.today
  end

  factory :transaction do             
     amount 35.0
     status true
     state "created"
     is_withholding_tax true
     frequency "weekly"
     customer_id nil
     start_date Date.today
     end_date  3.months.from_now
     created_at DateTime.now
     updated_at DateTime.now
     tax_withholding_amount 0.0
     remaining_amount 35.0
     reason nil
     weekday_hours 0
     weekend_hours 7
     total_weekday_hours 0
     total_weekend_hours 7
     probationary_period 1
     cancelled_by nil
     cancelled_at nil
     decline_reason_by_poster nil
     adjustment nil
     request_by nil
     old_transaction nil
  end

 # amount: nil,
 # employee_listing_id: 2,
 # status: true,
 # state: "initialized",
 # is_withholding_tax: true,
 # frequency: "weekly",
 # hirer_id: 1,
 # poster_id: 2,
 # customer_id: nil,
 # start_date: Mon, 06 Apr 2020,
 # end_date: Tue, 21 Apr 2020,
 # created_at: Mon, 06 Apr 2020 06:51:08 UTC +00:00,
 # updated_at: Mon, 06 Apr 2020 06:51:08 UTC +00:00,
 # tax_withholding_amount: nil,
 # remaining_amount: nil,
 # reason: nil,
 # weekday_hours: nil,
 # weekend_hours: nil,
 # total_weekday_hours: 0,
 # total_weekend_hours: 0,
 # probationary_period: nil,
 # cancelled_by: nil,
 # cancelled_at: nil,
 # decline_reason_by_poster: nil,
 # adjustment: nil,
 # request_by: nil,
 # old_transaction: nil>


 #  id: 594,
 # amount: 89.78,
 # employee_listing_id: 3,
 # status: true,
 # state: "created",
 # is_withholding_tax: true,
 # frequency: "weekly",
 # hirer_id: 1,
 # poster_id: 2,
 # customer_id: nil,
 # start_date: Sat, 04 Apr 2020,
 # end_date: Thu, 07 May 2020,
 # created_at: Sat, 04 Apr 2020 07:15:41 UTC +00:00,
 # updated_at: Sat, 04 Apr 2020 07:16:11 UTC +00:00,
 # tax_withholding_amount: 0.0,
 # remaining_amount: 89.78,
 # reason: nil,
 # weekday_hours: 1,
 # weekend_hours: 0,
 # total_weekday_hours: 5,
 # total_weekend_hours: 0,
 # probationary_period: 1,
 # cancelled_by: nil,
 # cancelled_at: nil,
 # decline_reason_by_poster: nil,
 # adjustment: nil,
 # request_by: nil,
 # old_transaction: nil>


  factory :company do
     name "test game"
     acn "8978"
     address_1 "Treasury Casino and Hotel Brisban, William Street"
     address_2 "28 Nerrigundah Drive"
     city "Brisbane City QLD"
     state "ACT"
     country "Australia"
     post_code 5676
     contact_no "0412456675"
     created_at DateTime.now
     updated_at DateTime.now
     role "Director/Owner"
  end


  factory :conversation do
		created_at DateTime.now
    updated_at DateTime.now
  end

  factory :message do
    content "Test message for sparestaff"
    read false
  end

 # User is sender
  factory :user do
    first_name  'test'
    last_name   'john'
    email       { Faker::Internet.email }
    password     '123456'
    password_confirmation '123456'
  end  

  factory :employee_listing do
		 classification_id 100
		 title "test bugs"
		 first_name "james"
		 last_name "clark"
		 tfn "5656"
		 birth_year 1991
		 address_1 ""
		 address_2 "Melbourne Central"
		 city "Melbourne"
		 state "ACT"
		 country "Australia"
		 post_code 5676
		 residency_status "Permanent Resident/Citizen"
		 other_residency_status ""
		 verification_type "Australian Driver Licence"
		 gender "male"
		 has_vehicle false
		 skill_description "Test skill_description in sparestaff"
		 optional_comments ""
		 published true
		 lister_type "Company"
		 listing_step 6
		 available_in_holidays true
		 weekday_price 0.2e2
		 holiday_price 0.5e2
		 minimum_working_hours 0
		 start_publish_date Date.today + 2.days
		 end_publish_date 3.months.from_now
		 weekend_price 0.678988e3
         latitude 28.7040592
         longitude 77.1024902
  end
end