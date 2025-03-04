require_relative 'test_helper'

module Ordering
  class MarkOrderAsPaidTest < ActiveSupport::TestCase
    include TestPlumbing

    cover 'Ordering::OnMarkOrderAsPaid*'

    test 'draft order could not be marked as paid' do
      aggregate_id = SecureRandom.uuid
      product = ProductCatalog::Product.create(name: 'test')
      arrange(
        AddItemToBasket.new(order_id: aggregate_id, product_id: product.id)
      )

      assert_raises(Order::NotSubmitted) do
        act(
          MarkOrderAsPaid.new(
            order_id: aggregate_id,
            transaction_id: SecureRandom.hex(16)
          )
        )
      end
    end

    test 'submitted order will be marked as paid' do
      aggregate_id = SecureRandom.uuid
      stream = "Ordering::Order$#{aggregate_id}"
      product = ProductCatalog::Product.create(name: 'test')
      customer = Customer.create(name: 'dummy')
      arrange(
        AddItemToBasket.new(order_id: aggregate_id, product_id: product.id),
        SubmitOrder.new(
          order_id: aggregate_id,
          order_number: '2018/12/1',
          customer_id: customer.id
        )
      )

      transaction_id = SecureRandom.hex(16)

      assert_events(
        stream,
        OrderPaid.new(
          data: {
            order_id: aggregate_id,
            transaction_id: transaction_id
          }
        )
      ) do
        act(
          MarkOrderAsPaid.new(
            order_id: aggregate_id,
            transaction_id: transaction_id
          )
        )
      end
    end

    test 'expired order cannot be marked as paid' do
      aggregate_id = SecureRandom.uuid
      product = ProductCatalog::Product.create(name: 'test')
      customer = Customer.create(name: 'dummy')
      arrange(
        AddItemToBasket.new(order_id: aggregate_id, product_id: product.id),
        SubmitOrder.new(
          order_id: aggregate_id,
          order_number: '2018/12/1',
          customer_id: customer.id
        ),
        SetOrderAsExpired.new(order_id: aggregate_id)
      )

      assert_raises(Order::OrderHasExpired) do
        act(
          MarkOrderAsPaid.new(
            order_id: aggregate_id,
            transaction_id: SecureRandom.hex(16)
          )
        )
      end
    end
  end
end
