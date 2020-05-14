class CreateStaticContents < ActiveRecord::Migration[5.2]
  def change
    create_table :static_contents do |t|
      t.attachment :site_logo

      t.timestamps
    end
  end
end
