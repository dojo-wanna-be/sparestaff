class AddAttachmentVerificationFrontImageToEmployeeListings < ActiveRecord::Migration[5.2]
  def self.up
    change_table :employee_listings do |t|
      t.attachment :verification_front_image
    end
  end

  def self.down
    remove_attachment :employee_listings, :verification_front_image
  end
end
