require 'open-uri'

# TODO: cleanup
class NewListingParser

	def parse_url(url)
		page = Nokogiri::HTML(open(url)) do |config|
  		config.strict.nonet.noblanks
		end
		parse(page)
	end

	def scrape_url(url)
		page = Nokogiri::HTML(open(url)) do |config|
  		config.strict.nonet.noblanks
		end
	end

	def parse(html)
		general_summaries	= []
		detailed_reports	= []
		images_links			= []

		# get the summary
		html.css('tbody tr').each do |link|
			general_summaries << link
		end

		# temporary for tests
		general_summaries.each{ |summary|
			mls_id = extract_summary_attributes(summary)['ml_num']
			search_str = "div#"
			detailed_reports << html.css("#{search_str}#{mls_id}")
		}

		print_date = extract_print_date(html)

		# fetch all images links
		html.css("img").each do |link|
		 images_links << link
		end

		# build listing data
		build_entries(general_summaries, detailed_reports, images_links, print_date)
	end

	def bulk_import(file_path)
		line_num=0
		File.open(file_path).each do |line|
		  print "#{line_num += 1} #{line}"
		  parse(line)
		end
	end

private

	DATE_PATH 								= "//*[@id='form1']/div[3]/div[1]/div/div[3]"
	REPORTS_NEW_PATH					= "div[class='reports view-pm'] div"
	REPORTS_SOLD_PATH 				= "div[class='reports view-pm'] div"
	SUMMARY_PATH 							= "tbody tr"
	IMAGES_PATH								= "img"
	PHOTO_NOT_EXIST 					= "http://static.stratusmls.com/StratusMLS/3.6/Images/PhotoNotAvailable.png"

	def extract_print_date(page)
		begin
			header = page.css("div[class=header]").css("div")[5].text
			regex = /\d{1,2}\/\d{1,2}\/\d{4}/
			header[regex]
		end
		rescue
			nil
	end

	def build_entries(raw_summaries, raw_detailed_reports, raw_images_links, print_date)
		detailed_report_attributes 	= []
		summary_attributes = []
		images = {}

		raw_summaries.each{ |summary|
			summary_attributes.push(extract_summary_attributes(summary))
		}

		raw_detailed_reports.each{ |detail_report|
			parsed_detailes = extract_detailed_attributes(detail_report)
			detailed_report_attributes.push(parsed_detailes) unless parsed_detailes.blank?
		}

		# extract images links
		images = extract_images_urls(raw_images_links)

		# build unique listings
		mls_ids = summary_attributes.map{|summary| summary['ml_num']}

		hash = {}
		mls_ids.each{|mls_id|
			inner_hash = {}
			inner_hash['summary_attributes'] = summary_attributes.select{|sa| sa["ml_num"] == mls_id }
			inner_hash['detailed_report'] = detailed_report_attributes.select{|ra| ra["MLS#:"] == mls_id}
			inner_hash['images'] = images[mls_id]
			inner_hash['print_date'] = print_date
			hash[mls_id] = inner_hash
		}
		hash
	end

	def extract_detailed_attributes(property_form)
		form_items = []
		entry_detailed_attributes = {}

		property_form.css("span[class = 'formitem formfield']").each do |form_item|
			form_items << form_item
		end

		form_items.each{|item|
			if item.css('label').text.present? && item.css('span').text.present?
				entry_detailed_attributes[item.css('label').text] = item.css('span').text
			end
		}
		entry_detailed_attributes
	end

	def extract_images_urls(images_data)
		images_links = {}
		images_data.each{|image|
			urls = []

			if image.as_json[0][1].blank?
				return
			end

			urls << image.as_json[0][1]
			mls_id = extract_mls_id_from_image_url(image.as_json[0][1])

			if image.has_attribute?('data-multi-photos')
				images = JSON.parse(image.as_json[3][1])
				images['multi-photos'].each{ |item|
					urls << item['url'] unless item['url'].blank?
				}
			end
			images_links[mls_id] = urls.uniq
		}
		images_links
	end

	def extract_mls_id_from_image_url(url)
		begin
			return nil if PHOTO_NOT_EXIST == url
			end_index 	= url.index('.jpg') - 1 rescue nil
			start_index = end_index - 7
			mls_id 			= url[start_index..end_index]
		end
		rescue
			puts "extract_mls_id_from_image_url Failed, URL #{url}"
	end

	def extract_summary_attributes(summary_form)
		hash = Hash.from_xml(summary_form.to_s)
		extra_details 	= JSON.parse(hash["tr"]["data_pop_up"])
	end

	def create_listing(html)
		Listing.create!(raw_email: html.to_s)
	end

end
