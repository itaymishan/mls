# == Schema Information
#
# Table name: rent_listings
#
#  id                   :integer          not null, primary key
#  mls_id               :string           not null
#  status               :integer
#  list_date            :datetime
#  rent_date            :datetime
#  last_fetched_status  :datetime
#  days_on_market       :integer
#  expected_return_rate :float
#  asking_price         :integer
#  closing_price        :integer
#  taxes                :integer
#  address              :string
#  postal               :string
#  longitude            :float
#  latitude             :float
#  home_type            :integer
#  home_style           :integer
#  rooms_total          :integer
#  family_rooms         :integer
#  bedrooms             :integer
#  washrooms            :integer
#  kitchens             :integer
#  basement_type        :integer
#  basement_rooms       :integer
#  basement_bedrooms    :integer
#  basement_washrooms   :integer
#  basement_kitchens    :integer
#  heat_type            :string
#  air_conditioner      :string
#  sqft_from            :float
#  sqft_to              :float
#  num_of_stories       :integer
#  parking_spaces       :integer
#  garage               :string
#  lot_length           :float
#  lot_width            :float
#  apx_age              :string
#  ammenities           :string
#  pool                 :string
#  water                :string
#  sewer                :string
#  exterior             :string
#  ammenities_near_by   :string
#  cross_streets        :string
#  remarks              :text
#  extras               :text
#  raw_data             :jsonb
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class RentListing < ActiveRecord::Base

  reverse_geocoded_by :latitude, :longitude
  # after_validation :reverse_geocode  # auto-fetch address

  enum status: [ :active, :leased, :unknown, :not_found ]
  enum basement_type: [ :finished, :apartment, :unfinished, :crawl_space, :no_basement]
  enum home_type: [ :detached, :semi_detached, :condominum, :other ]

  scope :check_statusable, -> {
    where(status: RentListing.statuses[:active])
  }

  def fetch_current_nearby(margin=0.04)
    RealtorExtractorService.new.fetch_by_geo_location(self.latitude, self.longitude, margin)
  end

  def check_status
    url = 'https://api2.realtor.ca/Listing.svc/PropertySearch_Post'
    body = "CultureId=1&ApplicationId=1&ReferenceNumber=#{mls_id}&IncludeTombstones=1"
    result = HttpAdapter.post(body, url)
    if result['Paging']['TotalPages'] < 1
      status = 3
      save
    end
  end

end
