# TODO: cleanup
class ListingDataAdapterService

  def initialize(params)
    @info = params
  end

  def create_listing
    begin
      mls_id          = @info[0]
      summary_info    = @info[1]['summary_attributes'][0]
      detailed_report = @info[1]['detailed_report'][0]
      images_links    = @info[1]['images']
      print_date      = @info[1]['print_date']

      @property =  Property.find_or_create_by(mls_id: mls_id)
      @property.parsed_data = @info

      # Summary data
      @property.mls_id = mls_id
      @property.address       = summary_info['addr'] rescue nil
      @property.street_name   = parse_address(summary_info['addr'])[:street_name] rescue nil
      @property.street_number = parse_address(summary_info['addr'])[:street_number] rescue nil
      @property.longitude    = summary_info['longitude'].to_f rescue nil
      @property.latitude      = summary_info['latitude'].to_f rescue nil
      @property.municipality  = summary_info['municipality'] rescue nil
      @property.home_type     = summary_info['type_own1_out'] rescue nil
      @property.home_style    = summary_info['style'] rescue nil
      @property.postal        = parse_zipcode(summary_info['zip']) rescue nil

      if detailed_report.blank?
        @property.listing_status  = summary_info['lsc'] rescue nil
        @property.bedrooms    = summary_info['br'].to_i rescue nil
        @property.washrooms   = summary_info['bath_tot'].to_i rescue nil

        if @property.listing_status == 'New'
            @property.list_price = summary_info['lp_dol'].to_i rescue nil
        elsif @property.listing_status == 'Sld'
            @property.sale_price = summary_info['lp_dol'].to_i rescue nil
        elsif  @property.listing_status == 'Lsd'
            @property.leased_price = summary_info['lp_dol'].to_i rescue nil
        end
      end

      if detailed_report.present?
        # Report data
        @property.for = detailed_report['For:'] rescue nil
        @property.listing_status  = detailed_report['Last Status:'] rescue nil
        @property.leased_date     = parse_date(detailed_report['Leased Date:']) rescue nil
        @property.sold_date = parse_date(detailed_report['Sold Date:']) rescue nil
        @property.apt_unit  = nil

        @property.bedrooms  = parse_bedrooms(detailed_report['Bedrooms:'])[:main].to_i rescue nil
        @property.washrooms = parse_washrooms(detailed_report['Washrooms:'])[:main].to_i rescue nil
        @property.basement_bedrooms  = parse_bedrooms(detailed_report['Bedrooms:'])[:basement].to_i rescue nil
        @property.basement_washrooms = parse_washrooms(detailed_report['Washrooms:'])[:basement].to_i rescue nil

        @property.kitchens  = parse_kitchens(detailed_report['Kitchens:'])[:main].to_i rescue nil
        @property.basement_kitchens  = parse_kitchens(detailed_report['Kitchens:'])[:basement].to_i rescue nil

        @property.total_rooms  = parse_total_rooms(detailed_report['Rms:'])[:main].to_i rescue nil
        @property.basement_rooms  = parse_total_rooms(detailed_report['Rms:'])[:basement].to_i rescue nil

        @property.sqft_from = nil
        @property.sqft_to   = nil
        @property.basement  = detailed_report['Basement:'] rescue nil
        @property.fronting_on     = detailed_report['Fronting On:'] rescue nil
        @property.family_rooms    = detailed_report['Fam Rm:'].to_i rescue nil
        @property.heat_type       = detailed_report['Heat:'] rescue nil
        @property.air_conditioner = detailed_report['A/C:'] rescue nil
        @property.exterior  = detailed_report['Exterior:'] rescue nil
        @property.drive     = detailed_report['Drive:'] rescue nil
        @property.garage    = detailed_report['Garage:'] rescue nil
        @property.parking_spaces = detailed_report['Park Spcs:'].to_i rescue nil
        @property.water = detailed_report['Water:'] rescue nil
        @property.sewer = detailed_report['Sewers:'] rescue nil
        @property.lot   = detailed_report['Lot:'] rescue nil
        @property.apx_age   = detailed_report['Apx Age:'] rescue nil
        @property.apx_sqft  = detailed_report['Apx Sqft:'] rescue nil
        @property.lot_length  = parse_lot(detailed_report['Lot:'])[:length] rescue nil
        @property.lot_width   = parse_lot(detailed_report['Lot:'])[:width] rescue nil
        @property.rooms = detailed_report['Rms:'].to_i rescue nil
        @property.pool  = detailed_report['Pool:'] rescue nil
        @property.cross_streets = detailed_report['Dir/Cross St:'] rescue nil
        @property.last_status   = detailed_report['Last Status:'] rescue nil
        @property.list_price    = parse_price(detailed_report['List:']).to_i rescue nil
        @property.leased_price  = parse_price(detailed_report['List:']).to_i rescue nil
        # @property.listing_type = detailed_report['Basement:']

        @property.sale_price  = parse_price(detailed_report['Sold:']).to_i rescue nil
        @property.dom   = detailed_report['DOM:'] rescue nil
        @property.taxes = parse_taxes(detailed_report['Taxes:']).to_f rescue nil
        @property.client_remarks = detailed_report['Client Remks'] rescue nil
        @property.extras = detailed_report['Extras:'] rescue nil
        @property.images_links = images_links rescue nil
        @property.print_date = parse_date(print_date) rescue nil
      end

    rescue => e
      puts "parser::=> exception #{e.class.name} : #{e.message}"
      @property.save!
    end
    @property.save!
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

end
