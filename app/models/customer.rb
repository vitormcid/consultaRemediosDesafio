class Customer < ApplicationRecord
  has_many :carts
  
  def name
 	self[:name]&.titleize
  end

end

