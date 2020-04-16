require 'rails_helper'

RSpec.describe Classification, type: :model do

	describe "Import the Classification" do
    it "#import_csv" do
      classification = Classification.import_csv("public/classification.csv")
      expect(classification).to eq(true)      
    end
	end
  
end
