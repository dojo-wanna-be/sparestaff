module Attachmentable
  extend ActiveSupport::Concern

  module ClassMethods
    def has_attachment(name, options = {})
      if Rails.env.production? || Rails.env.staging?
        # For production and staging environments, use s3 for file uploading.
        s3_domain = 'amazonaws.com'
        s3_region = ENV['S3_REGION']
        s3_host_name = "s3-#{s3_region}.#{s3_domain}"

        options[:path]            ||=  "/sparestaff/:class/:attachment/:id_partition/:style/:filename"
        options[:storage]         ||= :s3
        options[:s3_credentials]  ||= File.join(Rails.root, 'config', 'amazon_s3.yml')
        options[:s3_protocol]     ||= 'https'
        options[:s3_region]       ||= s3_region
        options[:s3_host_name]    ||= s3_host_name
      else
        # For local Dev/Test envs, use the default filesystem
        options[:path]  ||= ":rails_root/public:url"
        options[:url]   ||= "/system/:class/:attachment/:id_partition/:style/:filename"
      end

      # pass things off to paperclip.
      has_attached_file name, options
    end
  end
end
