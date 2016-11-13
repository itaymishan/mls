# TODO: cleanup
class EmailWorker
  @queue = :data_extractor

  def self.perform
    urls = GmailService.fetch_urls
    urls.each{|url|
      Page.create(url: url)
    }
  end
end
