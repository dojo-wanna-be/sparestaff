class RemoveLanguageCodeFromLanguages < ActiveRecord::Migration[5.2]
  def change
    remove_column :languages, :language_code, :string
  end
end
