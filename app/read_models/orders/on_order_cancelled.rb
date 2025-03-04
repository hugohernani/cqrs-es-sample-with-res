module Orders
  class OnOrderCancelled
    def call(event)
      order = Order.find_by_uid(event.data[:order_id])
      order.state = "Cancelled"
      order.save!
    end
  end
end
