# == Schema Information
#
# Table name: entries
#
#  id             :integer          not null, primary key
#  mls_id         :string
#  address        :string
#  street_name    :string
#  street_number  :string
#  listing_status :string
#  municipality   :string
#  apt_unit       :string
#  beds           :integer
#  wr             :integer
#  lsc            :string
#  list_price     :integer
#  sale_price     :integer
#  postal         :string
#  listing_type   :string
#  dom            :integer
#  taxes          :integer
#  client_remarks :text
#  raw_data       :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Entry < ActiveRecord::Base

end
