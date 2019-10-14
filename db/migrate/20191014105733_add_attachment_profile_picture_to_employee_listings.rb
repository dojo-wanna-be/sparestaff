class AddAttachmentProfilePictureToEmployeeListings < ActiveRecord::Migration[5.2]
  def self.up
    change_table :employee_listings do |t|
      t.attachment :profile_picture
    end
  end

  def self.down
    remove_attachment :employee_listings, :profile_picture
  end
end
