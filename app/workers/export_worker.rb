# TODO: cleanup
class ExportWorker
  @queue = :data_extractor

  def self.perform
    Property.not_exported.each{|p|
      res = MlsEmailDataAdapter.new(p.parsed_data).create_data_entry; p.exported_at = DateTime.now if res; p.save!
    }
    RealtorEntry.not_exported.each{|re|
      res = RealtorDataAdapter.new(re.data).create_data_entry; re.exported_at = DateTime.now if res; re.save!
    }
  end
end
