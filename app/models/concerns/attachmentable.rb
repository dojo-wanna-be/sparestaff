module Attachmentable
  extend ActiveSupport::Concern

  module ClassMethods
    def has_attachment(name, options = {})

      # Need to setup s3 credentials to make it work
      if false #Rails.env.production? || Rails.env.staging?
        modal_name    = self.table_name.singularize
        attachment_folder = "/sparestaff/#{modal_name}"
        attachment_path     = "#{attachment_folder}/:id/:style/:filename"

        options[:path]            ||= attachment_path
        options[:storage]         ||= :s3
        options[:s3_credentials]  ||= File.join(Rails.root, 'config', 'amazon_s3.yml')
        options[:s3_protocol]     ||= 'https'
      else
        # For local Dev/Test envs, use the default filesystem, but separate the environments
        # into different folders, so you can delete test files without breaking dev files.
        options[:path]  ||= ":rails_root/public:url"
        options[:url]   ||= "/system/:class/:attachment/:id_partition/:style/:filename"
      end

      # pass things off to paperclip.
      has_attached_file name, options
    end
  end
end
