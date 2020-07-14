class Cart < ApplicationRecord
  belongs_to :customer
  has_many :cart_items

  def add_item(medicine_id, quantity)
  	CartItem.transaction do  		
		medicine = Medicine.find(medicine_id)
		medicine.stock -= quantity
		medicine.save!

  		CartItem.create(cart_id: id, medicine_id: medicine_id, quantity: quantity)		
  	end
  end

  def total_price
  	cart_items.map{|c| c.medicine.value * c.quantity}.sum
  end

end
