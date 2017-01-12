class HttpAdapter

  # Make POST request
  def self.post(body, url)
    begin
      res = HTTParty.post(url,
                {
                  :body => body,
                  :headers => { 'Content-Type' => 'application/x-www-form-urlencoded' }
                 })
    rescue => exception
      puts exception
    end
  end
end
