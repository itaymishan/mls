while true do Property.all.sample.fetch_current_nearby ; i = i+1 ; sleep(5) end
RealtorEntry.all.each{|re| RealtorDataAdapter.new(re.data).create_data_entry}
RealtorEntry.all.each{|re| RealtorDataAdapter.new(re.data).create_data_entry}
i = 0; while i<20 do Property.all.sample.fetch_current_nearby ; i = i+1 ; sleep(20) end
i = 0; while i<200 do Property.all.sample.fetch_current_nearby ; i = i+1 ; sleep(2) end
Property.not_exported.each{|p| res = MlsEmailDataAdapter.new(p.parsed_data).create_data_entry; p.exported_at = DateTime.now if res; p.save!}
RealtorEntry.not_exported.each{|re| res = RealtorDataAdapter.new(re.data).create_data_entry; re.exported_at = DateTime.now if res; re.save!}
EmailWorker.perform
ExportWorker.perform
i = 0; while i<20 do SaleListing.all.sample.fetch_current_nearby ; i = i+1 ; sleep(20) end
i = 0; while i<2000 do RentListing.all.sample.fetch_current_nearby ; i = i+1 ; sleep(1) end
