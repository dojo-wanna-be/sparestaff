class CreateFrequentlyAskQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :frequently_ask_questions do |t|
      t.integer :section_type
      t.text :question
      t.text :answer

      t.timestamps
    end
  end
end
