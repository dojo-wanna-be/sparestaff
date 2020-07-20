class ApplicationRecord < ActiveRecord::Base
  include Attachmentable
  self.abstract_class = true
end
