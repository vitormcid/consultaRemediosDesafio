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



################# Extra task ####################

  def best_price
    total_price - best_discount
  end

  def best_discount
    linearized_items = Cart.linearize_items(cart_items)
    groups  = []

    #finding the ideal number of groups
    most_frequent_item = linearized_items.uniq.max_by{ |i| linearized_items.count( i ) }
    number_of_groups = linearized_items.count(most_frequent_item)
    number_of_groups.times{groups << []}

    #initializing variables
    value_position = 0
    discount_values = []  
    count = [0] 

    #checking which combination generates the biggest discount
    (0..number_of_groups-1).each_with_index do |n,i|      
      copy_groups = Marshal.load( Marshal.dump(groups) )
      Cart.fill_groups(linearized_items,copy_groups,number_of_groups,i,discount_values,count)
    end

    discount_values.present? ? discount_values.max() : 0
  end

  def self.fill_groups(linearized_items,groups,number_of_groups,value_position,discount_values,count)
    #recursion stop condition
    unless linearized_items.present?
      actual_discount =  discount_calc(groups)          
      discount_values << actual_discount.round(2)      
      return
    end

    return if groups[value_position].include?(linearized_items[0])

    #filling the groups recursively
    groups[value_position] << linearized_items[0]

    (0..number_of_groups-1).each_with_index do |n,i|       
      copy_groups = Marshal.load( Marshal.dump(groups) )

      fill_groups(linearized_items.drop(1),copy_groups,number_of_groups,i,discount_values,count)
    end
  end

  def self.linearize_items(cart_items)
    linearized_items = []
    cart_items.each do |cart_item|
      cart_item.quantity.times {linearized_items << cart_item.medicine.id}
    end

    linearized_items
  end

  def self.discount_calc(groups)
    discount_percentages = [0,0,0.05,0.10,0.20,0.25]
    total_discount = 0

    groups.each do |group|
      if group.size > 5
        discount_percentage = 25
      else
        discount_percentage = discount_percentages[group.size]
      end

      total_group_discount = group.size * 8 * discount_percentage
      total_discount += total_group_discount
    end
    total_discount
  end

################# End of extra task ###############

end
