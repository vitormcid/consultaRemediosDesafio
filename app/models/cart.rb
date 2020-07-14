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


  def best_discount
    linearized_items = Cart.linearize_items(cart_items)
    groups  = []

    number_of_groups = linearized_items.count    
    number_of_groups.times{groups << []}
    value_position = 0

  end

  def self.fill_groups(linearized_items,groups,number_of_groups,value_position)
    unless linearized_items.present?      
      groups = []
     return
    end


    copy_groups = groups.dup
    copy_groups[value_position] << linearized_items[0]

    (0..number_of_groups-1).each_with_index do |n,i|
      fill_groups(linearized_items.drop(1),copy_groups.dup,number_of_groups,i)
    end
  end

  def self.linearize_items(cart_items)
    linearized_items = []
    cart_items.each do |cart_item|
      cart_item.quantity.times {linearized_items << cart_item.medicine.id}
    end

    linearized_items
  end


end
