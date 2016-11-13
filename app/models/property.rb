# == Schema Information
#
# Table name: properties
#
#  id                   :integer          not null, primary key
#  mls_id               :string
#  for                  :string
#  address              :string
#  street_name          :string
#  street_number        :string
#  longitude            :float
#  latitude             :float
#  listing_status       :string
#  municipality         :string
#  home_type            :string
#  home_style           :string
#  apt_unit             :string
#  bedrooms             :integer
#  washrooms            :integer
#  kitchens             :integer
#  sqft_from            :integer
#  sqft_to              :integer
#  basement             :string
#  fronting_on          :string
#  family_rooms         :integer
#  heat_type            :string
#  air_conditioner      :string
#  exterior             :string
#  drive                :string
#  garage               :string
#  parking_spaces       :integer
#  water                :string
#  sewer                :string
#  lot                  :string
#  lot_length           :float
#  lot_width            :float
#  rooms                :integer
#  pool                 :string
#  cross_streets        :string
#  last_status          :string
#  list_price           :integer
#  leased_price         :integer
#  sale_price           :integer
#  leased_date          :datetime
#  sold_date            :datetime
#  postal               :string
#  listing_type         :string
#  dom                  :integer
#  taxes                :integer
#  client_remarks       :text
#  images_links         :jsonb
#  print_date           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  extras               :string
#  apx_age              :string
#  apx_sqft             :string
#  parsed_data          :jsonb
#  basement_bedrooms    :integer
#  basement_washrooms   :integer
#  basement_kitchens    :integer
#  total_rooms          :integer
#  basement_rooms       :integer
#  expected_return_rate :float
#  exported_at          :datetime
#

# TODO: Remove model
class Property < ActiveRecord::Base

  # validations
  validates :mls_id, uniqueness: true

  # callbacks
  before_save :calculate_expected_return_rate

  # scopes
  scope :sold, -> {
    where.not(sold_date: nil)
  }

  scope :rented, -> {
    where.not(leased_date: nil)
  }

  scope :not_exported, -> {
    where(exported_at: nil)
  }

  def calculate_expected_return_rate
    # same street, municipality, texas, sale_price, leased_price
    if self.sale_price.present?
      transaction_price = self.sale_price
    elsif self.list_price.present?
      transaction_price = self.list_price
    else
      return nil
    end
    rented_avarage = Property.where(municipality: self.municipality)
                      .where(street_name: self.street_name)
                      .where(bedrooms: self.bedrooms)
                      .where(washrooms: self.washrooms)
                      .where(last_status: 'Lsd')
                      .average(:list_price)

    if rented_avarage == 0 || rented_avarage.blank?
      return
    end
    calc_return_rate = ( (rented_avarage * 12) / transaction_price ) rescue nil
    if calc_return_rate < 0.09 && calc_return_rate > 0
      self.expected_return_rate = calc_return_rate
    else
      self.expected_return_rate = nil
    end
  end

  def fetch_realtor
    body = HttpAdapter.body(longitude, longitude+10, latitude, latitude+10)
    res = HttpAdapter.post(body)
  end

  def compareables
    Property.where(street_name: self.street_name)
            .where(municipality: self.municipality)
  end

  def fetch_current_nearby
    RealtorExtractorService.new.fetch_by_geo_location(self.latitude, self.longitude, 0.04)
  end

  def create_task
    Resque.enqueue(RealtorWorker, self.id)
  end

end
