module Ordering
  class OnAddItemToBasket
    include CommandHandler

    def call(command)
      with_aggregate(Order, command.aggregate_id) do |order|
        order.add_item(command.product_id)
      end
    end
  end

  class OnCancelOrder
    include CommandHandler

    def call(command)
      with_aggregate(Order, command.aggregate_id) do |order|
        order.cancel
      end
    end
  end

  class OnMarkOrderAsPaid
    include CommandHandler

    def call(command)
      with_aggregate(Order, command.aggregate_id) do |order|
        order.confirm(command.transaction_id)
      end
    end
  end

  class OnRemoveItemFromBasket
    include CommandHandler

    def call(command)
      with_aggregate(Order, command.aggregate_id) do |order|
        order.remove_item(command.product_id)
      end
    end
  end
  class OnSetOrderAsExpired
    include CommandHandler

    def call(command)
      with_aggregate(Order, command.aggregate_id) do |order|
        order.expire
      end
    end
  end
  class OnSubmitOrder
    include CommandHandler

    def initialize(number_generator:)
      @number_generator = number_generator
    end

    def call(command)
      with_aggregate(Order, command.aggregate_id) do |order|
        order_number = number_generator.call
        order.submit(order_number, command.customer_id)
      end
    end

    private

    attr_accessor :number_generator
  end
end



