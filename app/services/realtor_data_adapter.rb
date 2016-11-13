# TODO: cleanup
class RealtorDataAdapter

  def initialize(params)
    @info = params
  end

  def create_data_entry
    begin
      return if @info.blank?
      if @info['Property']['Price'].present?
        create_sale_entry
      elsif @info['Property']['LeaseRent'].present?
        create_rent_entry
      else
        puts "RealtorDataAdapter fail to parse #{@info}"
      end
    rescue => e
      puts "parser::=> exception #{e.class.name} : #{e.message}"
    end
  end

  def create_sale_entry
    sale_listing = SaleListing.find_or_create_by(mls_id: @info['MlsNumber'])
    sale_listing.asking_price = parse_sale_asking_price(@info['Property']['Price'])
    sale_listing.longitude = @info['Property']['Address']['Longitude'].to_f
    sale_listing.latitude   = @info['Property']['Address']['Latitude'].to_f
    sale_listing.address    = @info['Property']['Address']['AddressText'].gsub('|', ',')
    sale_listing.washrooms  = parse_washrooms(@info['Building']['BathroomTotal'])[:main].to_i
    sale_listing.basement_washrooms = parse_washrooms(@info['Building']['BathroomTotal'])[:basement].to_i
    sale_listing.bedrooms   = parse_bedrooms(@info['Building']['Bedrooms'])[:main].to_i
    sale_listing.basement_bedrooms = parse_bedrooms(@info['Building']['Bedrooms'])[:basement].to_i rescue nil
    sale_listing.num_of_stories = @info['Building']['StoriesTotal'].to_i
    sale_listing.postal   = @info['Land']['PostalCode']
    sale_listing.remarks  = @info['PublicRemarks']
    sale_listing.status   = SaleListing.statuses['active']
    sale_listing.raw_data = @info
    sale_listing.save!
  end

  def create_rent_entry
    rent_listing = RentListing.find_or_create_by(mls_id: @info['MlsNumber'])
    rent_listing.asking_price = parse_rent_asking_price(@info['Property']['LeaseRent'])
    rent_listing.longitude  = @info['Property']['Address']['Longitude'].to_f
    rent_listing.latitude   = @info['Property']['Address']['Latitude'].to_f
    rent_listing.address    = @info['Property']['Address']['AddressText'].gsub('|', ',')
    rent_listing.washrooms  = parse_washrooms(@info['Building']['BathroomTotal'])[:main].to_i
    rent_listing.basement_washrooms = parse_washrooms(@info['Building']['BathroomTotal'])[:basement].to_i
    rent_listing.bedrooms   = parse_bedrooms(@info['Building']['Bedrooms'])[:main].to_i
    rent_listing.basement_bedrooms = parse_bedrooms(@info['Building']['Bedrooms'])[:basement].to_i rescue nil
    rent_listing.num_of_stories = @info['Building']['StoriesTotal'].to_i
    rent_listing.postal   = @info['Land']['PostalCode']
    rent_listing.remarks  = @info['PublicRemarks']
    rent_listing.status   = RentListing.statuses['active']
    rent_listing.raw_data = @info
    rent_listing.save!
  end

  def parse_sale_asking_price(price_str)
    return 0 if price_str.blank?
    price_str.gsub!(',', '')
    price_str.gsub!('$', '')
    price_str.to_i
  end

  def parse_rent_asking_price(price_str)
    return 0 if price_str.blank?
    price_str.gsub!("\/Monthly", '')
    price_str.gsub!('$', '')
    price_str.gsub!(',', '')
    price_str.to_i
  end

  def parse_bedrooms(bedrooms_str)
    return nil if bedrooms_str.blank?
    arr = bedrooms_str.split(' ')
    hash = {main: arr[0].to_i, basement: arr[2]}
  end

  def parse_washrooms(washrooms_str)
    return nil if washrooms_str.blank?
    arr = washrooms_str.split(' ')
    hash = {main: arr[0].to_i, basement: arr[2]}
  end

  def parse_kitchens(kitchens_str)
    return nil if kitchens_str.blank?
    arr = kitchens_str.split(' ')
    hash = {main: arr[0].to_i, basement: arr[2]}
  end

  def parse_total_rooms(rooms_str)
    return nil if rooms_str.blank?
    arr = rooms_str.split(' ')
    hash = {main: arr[0].to_i, basement: arr[2]}
  end

end
