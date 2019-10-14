class AddAttachmentDocumentToRelevantDocuments < ActiveRecord::Migration[5.2]
  def self.up
    change_table :relevant_documents do |t|
      t.attachment :document
    end
  end

  def self.down
    remove_attachment :relevant_documents, :document
  end
end
