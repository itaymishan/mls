class SleepingJob
  @queue = :data_extractor

  def self.perform    
    puts 'I like to sleep'
    sleep 2
  end
end