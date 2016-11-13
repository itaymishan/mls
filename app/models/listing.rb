# == Schema Information
#
# Table name: listings
#
#  id         :integer          not null, primary key
#  raw_email  :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# TODO: Remove model
class Listing < ActiveRecord::Base

	# Validations
	validates :raw_email, presence: true

	def to_xml
		info_doc = Nokogiri::XML(self.raw_email)
	end

	def to_html
		info_doc = Nokogiri::HTML(self.raw_email)
	end

	def write_to_file(full_path)
		File.open(full_path, 'w') { |file| file.write(self.raw_email) }
	end

	def extract_data
		NewListingParser.new.parse(to_html)
	end
end
