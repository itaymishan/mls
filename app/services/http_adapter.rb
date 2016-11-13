class HttpAdapter

  # Make POST request
  def self.post(body, url)
    begin
      HTTParty.post(url,
                {
                  :body => body,
                  :headers => { 'Content-Type' => 'application/json' }
                 })
    rescue => exception
      puts exception
    end
  end
end
