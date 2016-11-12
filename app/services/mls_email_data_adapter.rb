class MlsEmailDataAdapter

  def initialize(params)
    @info = params
  end

  def create_data_entry
    begin
      mls_id          = @info[0]
      summary_info    = @info[1]['summary_attributes'][0]
      detailed_report = @info[1]['detailed_report'][0]
      images_links    = @info[1]['images']
      print_date      = @info[1]['print_date']

      if sale_listing?(summary_info['lp_dol'].to_i)
        create_sale_entry
      else
        create_rent_entry
      end
    rescue => e
      puts "parser::=> exception #{e.class.name} : #{e.message}"
    end
  end

  def create_sale_entry
    mls_id          = @info[0]
    summary_info    = @info[1]['summary_attributes'][0]
    detailed_report = @info[1]['detailed_report'][0]
    images_links    = @info[1]['images']
    print_date      = @info[1]['print_date']

    sale_listing = SaleListing.find_or_create_by(mls_id: mls_id)
    sale_listing.asking_price = summary_info['lp_dol'].to_i
    sale_listing.longitude    = summary_info['longitude'].to_f rescue nil
    sale_listing.latitude     = summary_info['latitude'].to_f rescue nil
    sale_listing.address      = summary_info['addr'] rescue nil
    sale_listing.washrooms    = summary_info['bath_tot'].to_i rescue nil
    sale_listing.bedrooms     = summary_info['br'].to_i rescue nil
    sale_listing.postal       = parse_zipcode(summary_info['zip']) rescue nil
    # sale_listing.home_type    = summary_info['type_own1_out'] rescue nil
    # sale_listing.home_style   = summary_info['style'] rescue nil
    sale_listing.status       = summary_info['lsc'] == 'New' ? SaleListing.statuses['active'] : SaleListing.statuses['sold']
    sale_listing.raw_data     = @info
    sale_listing.save!
  end

  def create_rent_entry
    mls_id          = @info[0]
    summary_info    = @info[1]['summary_attributes'][0]
    detailed_report = @info[1]['detailed_report'][0]
    images_links    = @info[1]['images']
    print_date      = @info[1]['print_date']

    rent_listing = RentListing.find_or_create_by(mls_id: mls_id)
    rent_listing.asking_price = summary_info['lp_dol'].to_i
    rent_listing.longitude    = summary_info['longitude'].to_f rescue nil
    rent_listing.latitude     = summary_info['latitude'].to_f rescue nil
    rent_listing.address      = summary_info['addr'] rescue nil
    rent_listing.washrooms    = summary_info['bath_tot'].to_i rescue nil
    rent_listing.bedrooms     = summary_info['br'].to_i rescue nil
    rent_listing.postal       = parse_zipcode(summary_info['zip']) rescue nil
    # rent_listing.home_type    = summary_info['type_own1_out'] rescue nil
    # rent_listing.home_style   = summary_info['style'] rescue nil
    rent_listing.status       = summary_info['lsc'] == 'New' ? RentListing.statuses['active'] : RentListing.statuses['leased']
    rent_listing.raw_data     = @info
    rent_listing.save!
  end

  def sale_listing?(price)
    price > RENT_MAX_PRICE
  end

  def parse_lot(str_lot)
    return nil if str_lot.blank?
    arr = str_lot.split(' ')
    hash = {width: arr[0].to_f, length: arr[2].to_f, unit: arr[3]}
  end

  def parse_date(date_str)
    return nil if date_str.blank?
    date = Date.strptime("1/22/2016","%M/%d/%Y")
  end

  def parse_address(address_str)
    white_space_index = address_str.index(' ')
    street_name   = address_str[white_space_index..address_str.size].strip
    street_number = address_str[0..white_space_index-1].strip
    hash = {street_name: street_name, street_number: street_number.to_i}
  end

  def parse_taxes(taxes_str)
    return nil if taxes_str.blank?
    arr = taxes_str.split(' ')
    arr[0].slice!('$')
    arr[0].slice!(',')
    arr[0]
  end

    def parse_price(price_str)
    return nil if price_str.blank?
    arr = price_str.split(' ')
    arr[0].slice!('$')
    arr[0].slice!(',')
    arr[0]
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

  # Apx Age : 51-99
  # Apx Sqft: 2000-2500
  def parse_sqft
  end

  def parse_acreage
  end

  def parse_zipcode(zipcode_str)
    return nil if zipcode_str.blank?
    zipcode_str.delete(' ')
  end


private

  RENT_MAX_PRICE = 15000

end
