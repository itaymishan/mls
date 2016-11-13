# == Schema Information
#
# Table name: realtor_entries
#
#  id          :integer          not null, primary key
#  data        :jsonb
#  mls_id      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  exported_at :datetime
#

class RealtorEntry < ActiveRecord::Base
  # validations
  validates :mls_id, uniqueness: true

  # scopes
  scope :not_exported, -> {
    where(exported_at: nil)
  }

  def self.extract_realtor
    Property.all.each{|prop|
      body = HttpAdapter.body(prop.longitude, prop.longitude+0.05, prop.latitude, prop.latitude+0.05)
      puts "PropID: #{prop.id}, coords: #{prop.longitude}, #{prop.latitude}"
      results = HttpAdapter.post(body)
      if results['Results'].present?
        results['Results'].each{|result|
          puts " This is the MLS number #{result['MlsNumber']}"
          RealtorEntry.create(mls_id: result['MlsNumber'], data: result)
        }
      end
    }
  end
end
