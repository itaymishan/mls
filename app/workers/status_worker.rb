# TODO: cleanup
class StatusWorker
  @queue = :data_validation

  def self.perform
    RentListing.check_statusable.find_each(batch_size: 50) do |rl|
      begin
        puts "Checking status of #{rl.mls_id}"
        sleep(2)
        url = 'https://api2.realtor.ca/Listing.svc/PropertySearch_Post'
        body = "CultureId=1&ApplicationId=1&ReferenceNumber=#{rl.mls_id}&IncludeTombstones=1"
        result = HttpAdapter.post(body, url)
        if result['Paging']['TotalPages'] < 1 || result['Results'][0]['StatusId'] == '10'
          puts "Not found: #{rl.mls_id}"
          rl.status = RentListing.statuses[:not_found]
          rl.save
        end
      rescue
      end
    end

    SaleListing.check_statusable.find_each(batch_size: 50) do |sl|
      begin
        puts "Checking status of #{sl.mls_id}"
        sleep(2)
        url = 'https://api2.realtor.ca/Listing.svc/PropertySearch_Post'
        body = "CultureId=1&ApplicationId=1&ReferenceNumber=#{sl.mls_id}&IncludeTombstones=1"
        result = HttpAdapter.post(body, url)
        if result['Paging']['TotalPages'] < 1 || result['Results'][0]['StatusId'] == '10'
          puts "Not found: #{sl.mls_id}"
          sl.status = RentListing.statuses[:not_found]
          sl.save
        end
      rescue
      end
    end

  end
end
