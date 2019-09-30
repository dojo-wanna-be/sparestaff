# == Schema Information
#
# Table name: languages
#
#  id            :bigint           not null, primary key
#  language      :string
#  language_code :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class LanguageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
