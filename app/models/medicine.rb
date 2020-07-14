class Medicine < ApplicationRecord
  validates :stock, numericality: { greater_than: 0 }
  
  def total
    (value? && quantity?) ? value * quantity : 0
  end
end
