class AddCustomFieldsToPosterToHirerReview < ActiveRecord::Migration[5.2]
  def change
    rename_table :poster_to_hirer_reviews, :reviews
    add_column :reviews, :public_feedback, :text
    add_column :reviews, :private_feedback, :text
    add_column :reviews, :work_environment_grade, :float
    add_column :reviews, :suitability_grade, :float
    add_column :reviews, :communication_grade, :float
    add_column :reviews, :employee_satisfaction_grade, :float
    add_column :reviews, :friendliness_grade, :float
    add_column :reviews, :punctuality_grade, :float
    add_column :reviews, :professionalism_grade, :float
    add_column :reviews, :knowledge_n_skills_grade, :float
    add_column :reviews, :management_skill_grade, :float
    add_column :reviews, :overall_experience, :string
    add_column :reviews, :recommendation, :string
  end
end
