_           = require 'underscore'
sd          = require('sharify').data
acct        = require 'accounting'
benv        = require 'benv'
sinon       = require 'sinon'
rewire      = require 'rewire'
Backbone    = require 'backbone'
fabricate   = require '../../../../test/helpers/fabricator.coffee'
OrderLineItem = require "../../../../models/order_line_item.coffee"
OrderLineItems = require "../../../../collections/order_line_items.coffee"
Order = require "../../../../models/order.coffee"
{ resolve } = require 'path'

ModalDialog = benv.requireWithJadeify(
  resolve(__dirname, '../../../../components/modal_dialog/view'),
  ['template']
)
OrderLineItemView = benv.requireWithJadeify(
  resolve(__dirname, '../../client/order_line_item_view'),
  ['orderLineItemTemplate', 'imagesTemplate']
)
OrderLineItemView.__set__ 'UploadForm', sinon.stub()
OrderLineItemView.__set__ 'ModalDialog', ModalDialog

describe 'OrderFormView', ->
  before (done) ->
    benv.setup ->
      benv.expose $: benv.require 'jquery'
      benv.expose jQuery: $
      window.$ = window.jQuery = $
      require '../../../../lib/vendor/jquery.are-you-sure.js'
      Backbone.$ = $
      done()

  after ->
    benv.teardown()

  beforeEach (done) ->
    sinon.stub Backbone, 'sync'
    done()

  afterEach ->
    Backbone.sync.restore()

  describe 'new item', ->
    describe 'tax item', ->
      beforeEach ->
        @orderLineItems = new OrderLineItems()
        @orderLineItems.add type: 'product', price: 1000, quantity: 2
        @order = new Order fabricate('order', currency_source: 'USD', exchange_rate: 30)
        @view = new OrderLineItemView
          type: 'tax'
          order: @order
          model: new OrderLineItem()
          orderLineItems: @orderLineItems

      describe '#initialize', ->
        it 'overrides the default value of attributes with options passed in', ->
          @view.type.should.equal 'tax'
          @view.order.should.equal @order

        it 'renders the normal mode of the view', ->
          _.isUndefined(@view.$('.order-line-item').attr('data-state')).should.be.ok

        it 'renders a hidden quantity input with value set to 1', ->
          @view.$('[name="quantity"][type="hidden"]').length.should.equal 1
          @view.$('[name="quantity"][type="hidden"]').val().should.equal '1'

        it 'renders a hidden price input with value set to 0', ->
          @view.$('[name="price"][type="hidden"]').length.should.equal 1
          @view.$('[name="price"][type="hidden"]').val().should.equal acct.toFixed(0, 0)

      describe '#edit', ->
        it 'renders the edit mode of the view', ->
          @view.edit()
          @view.$('.order-line-item').attr('data-state').should.equal 'editing'

      describe '#updateTaxMessage', ->
        it 'shows error messages when the input value is not a valid number', ->
          @view.$('.form-order-line-item [name="tax-rate"]').val 'this is not a number'
          @view.updateTaxMessage()
          @view.$('.subtotal-message').text().should.equal '單價必須為數字'

        it 'shows helper messages when the input value is a valid number', ->
          @view.$('.form-order-line-item [name="tax-rate"]').val '8'
          @view.updateTaxMessage()
          @view.$('.subtotal-message').text().should.containEql "#{@orderLineItems.total('product') * 8 / 100}"

      describe '#updateTax', ->
        describe 'new product item added', ->
          beforeEach ->
            @view.taxRate = 8
            @orderLineItems.add type: 'product', price: 1000, quantity: 1

          it 'updates the total price of product items', ->
            @orderLineItems.total('product').should.equal 1000 * 3

          it 'updates the price of the tax item model', ->
            @view.updateTax()
            @view.model.get('price').should.equal 1000 * 3 * 8 / 100

          it 'updates helper messages', ->
            @view.updateTax()
            @view.$('.subtotal-message').text().should.containEql "#{@orderLineItems.total('product') * 8 / 100}"

        describe 'remove product item from orderLineItems', ->
          beforeEach ->
            @view.taxRate = 8
            @orderLineItems.pop()

          it 'updates the total price of product items', ->
            @orderLineItems.total('product').should.equal 0

          it 'updates the price of the tax item model', ->
            @view.updateTax()
            @view.model.get('price').should.equal 0

      describe '#save', ->
        #
        describe 'all the data were changed', ->
          beforeEach ->
            @view.$('[name="tax-rate"]').val '10'
            @view.$('[name="notes"]').val '當地消費稅'
            @view.save($.Event('click'))

          it 'sets the order line item model attributes with correct values', ->
            @view.model.get('price').should.equal 2000 * 10 / 100

          it 'marks the @isCreated flag as true', ->
            @view.isCreated.should.be.ok

          it 'does not actually save the model to the server', ->
            Backbone.sync.called.should.not.be.ok

          it 'switches to normal mode', ->
            _.isUndefined(@view.$('.order-line-item').attr('data-state')).should.be.ok

          it 'sets the order notes with correct value', ->
            @view.model.get('notes').should.equal '當地消費稅'

          it 'updates the view with updated order line item attributes', ->
            @view.$('.item-price').text().should.equal acct.formatMoney(2000 * 10 / 100)
            @view.$('.order-line-item-preview .item-subtotal').text().should.equal acct.formatMoney(2000 * 10 / 100)

    _.each ['product', 'shipping', 'commission'], (type) ->
      describe "#{type} item", ->
        beforeEach ->
          @order = new Order fabricate('order', currency_source: 'USD', exchange_rate: 30.50)
          @view = new OrderLineItemView
            type: type
            order: @order
            model: new OrderLineItem()

        describe '#initialize', ->
          it 'initializes the attributes properly with default values', ->
            view = new OrderLineItemView
              order: @order
              model: new OrderLineItem()
            view.type.should.equal @view.defaults().type
            view.isCreated.should.equal false

          it 'overrides the default value of attributes with options passed in', ->
            @view.type.should.equal type
            @view.order.should.equal @order

          it 'stores a copy of the exchange rate in @oldFXRate', ->
            @view.oldFXRate.should.equal @order.get 'exchange_rate'

          it 'renders the normal mode of the view', ->
            _.isUndefined(@view.$('.order-line-item').attr('data-state')).should.be.ok

          it 'renders the shared part of the view properly', ->
            @view.$('[name="currency-source"]').length.should.equal 2

          if type is 'product'
            it 'renders the product-related view properly', ->
              @view.$('[name="quantity"]:not([type="hidden"])').length.should.equal 1
              @view.$('[name="quantity"]').val().should.equal '1'
              @view.$('[name="title"]').length.should.equal 1
              @view.$('[name="brand"]').length.should.equal 1
              @view.$('[name="url"]').length.should.equal 1
              @view.$('[name="image"]').length.should.equal 1
              @view.$('[name="color"]').length.should.equal 1
              @view.$('[name="size"]').length.should.equal 1

            it 'checks the currency source', ->
              @view.$('[name="currency-source"]:checked').val().should.equal 'USD'

            it 'fills in the price with 2 decimal places', ->
              @view.$('[name="price"]').val().should.equal acct.toFixed(0, 2)

          else
            it 'renders a hidden quantity input with value set to 1', ->
              @view.$('[name="quantity"][type="hidden"]').length.should.equal 1
              @view.$('[name="quantity"][type="hidden"]').val().should.equal '1'

            it 'checks the currency target', ->
              @view.$('[name="currency-source"]:checked').val().should.equal 'TWD'

            it 'fills in the price with 0 decimal places', ->
              @view.$('[name="price"]').val().should.equal acct.toFixed(0, 0)

        describe '#edit', ->
          it 'renders the edit mode of the view', ->
            @view.edit()
            @view.$('.order-line-item').attr('data-state').should.equal 'editing'

        describe '#updateSubtotalMessage', ->
          it 'hides the message if the selected currency source is TWD', ->
            @view.$('[name="currency-source"][value="TWD"]').prop('checked', true)
            @view.updateSubtotalMessage()
            @view.$('.subtotal-message').text().should.be.empty

          it 'shows an error message if the price value is not valid', ->
            @view.$('[name="price"]').val 'this is not a number'
            @view.updateSubtotalMessage()
            @view.$('.subtotal-message').text().should.equal '單價必須為數字'

          it 'shows a currency conversion message if needed', ->
            @view.$('[name="currency-source"][value="USD"]').prop('checked', true)
            @view.$('[name="price"]').val '150'
            @view.updateSubtotalMessage()
            @view.$('.subtotal-message').text().should.containEql "#{150 * @order.get('exchange_rate')}"

        describe '#orderChanged', ->
          describe 'exchange rate changed', ->
            beforeEach ->
              @view.model.set 'price', 100 * @order.get('exchange_rate')
              @order.set 'exchange_rate', 60

            it 'updates the price of the order line item model', ->
              @view.model.get('price').should.equal 100 * 60

            if type is 'product'
              it 'updates the view reflecting the new exchange rate', ->
                @view.$('[name="currency-source"]:checked').val().should.equal 'USD'
                @view.$('[name="price"]').val().should.equal acct.toFixed(100, 2)
                @view.$('.subtotal-message').text().should.containEql "#{100 * @order.get('exchange_rate')}"
            else
              it 'updates the view reflecting the new exchange rate', ->
                @view.$('[name="currency-source"]:checked').val().should.equal 'TWD'
                @view.$('[name="price"]').val().should.equal acct.toFixed(100 * @order.get('exchange_rate'))
                @view.$('.subtotal-message').text().should.be.empty

            it 'stores the new exchange rate in @oldFXRate', ->
              @view.oldFXRate.should.equal 60

          describe 'currency source changed', ->
            if type is 'product'
              it 'updates the view with the updated currency', ->
                @order.set 'currency_source', 'JPY'
                @view.$('[name="currency-source"]:checked').val().should.equal 'JPY'
            else
              it 'keeps target currency selected', ->
                @order.set 'currency_source', 'JPY'
                @view.$('[name="currency-source"]:checked').val().should.equal 'TWD'

        describe '#save', ->
          if type is 'product'
            describe 'only product data were changed', ->
              beforeEach ->
                @view = new OrderLineItemView
                  type: type
                  order: @order
                  model: new OrderLineItem(type: 'product', quantity: 1)
                @view.$('[name="title"]').val '2015 限量紀念包'
                @view.$('[name="brand"]').val 'A&F'
                @view.$('[name="url"]').val 'http://af.com/2015-bag'
                @view.$('[name="image"]').val 'http://af.com/2015-bag.jpg'
                @view.$('[name="color"]').val '米白色'
                @view.$('[name="size"]').val 'XL'
                @view.$('[name="description"]').val '2015 年新款，限量 300 個。'
                @view.save($.Event('click'))

              it 'sets the related product model attributes with correct values', ->
                product = @view.model.related().product
                product.get('title').should.equal '2015 限量紀念包'
                product.get('brand').should.equal 'A&F'
                product.get('urls').should.eql ['http://af.com/2015-bag']
                product.get('images').should.eql [{original: 'http://af.com/2015-bag.jpg'}]
                product.get('color').should.equal '米白色'
                product.get('size').should.equal 'XL'
                product.get('description').should.equal '2015 年新款，限量 300 個。'

              # Even only the product data were changed, we still need to re-render.
              it 'updates the view with updated product attributes', ->
                @view.$('.order-line-item-preview .item-brand').text().should.equal 'A&F'
                @view.$('.order-line-item-preview .item-title').text().should.equal '2015 限量紀念包'
                @view.$('.order-line-item-preview .item-color').text().should.equal '米白色'
                @view.$('.order-line-item-preview .item-size').text().should.equal 'XL'
                @view.$('.order-line-item-preview .item-image img').attr('src').should.equal 'http://af.com/2015-bag.jpg'

          describe 'all the data were changed', ->
            beforeEach ->
              @view.$('[name="currency-source"][value="USD"]').prop('checked', true)
              @view.$('[name="price"]').val '100'

              if type is 'product'
                @view.$('[name="quantity"]').val '2'
                @view.$('[name="title"]').val '2015 限量紀念包'
                @view.$('[name="brand"]').val 'A&F'
                @view.$('[name="url"]').val 'http://af.com/2015-bag'
                @view.$('[name="image"]').val 'http://af.com/2015-bag.jpg'
                @view.$('[name="color"]').val '米白色'
                @view.$('[name="size"]').val 'XL'
                @view.$('[name="description"]').val '2015 年新款，限量 300 個。'
              else
                @view.$('[name="notes"]').val '多退少補'

              @view.save($.Event('click'))

            it 'sets the order line item model attributes with correct values', ->
              @view.model.get('price').should.equal 100 * @order.get('exchange_rate')

            it 'marks the @isCreated flag as true', ->
              @view.isCreated.should.be.ok

            it 'does not actually save the model to the server', ->
              Backbone.sync.called.should.not.be.ok

            it 'switches to normal mode', ->
              _.isUndefined(@view.$('.order-line-item').attr('data-state')).should.be.ok

            if type is 'product'
              it 'sets the related product model attributes with correct values', ->
                product = @view.model.related().product
                product.get('title').should.equal '2015 限量紀念包'
                product.get('brand').should.equal 'A&F'
                product.get('urls').should.eql ['http://af.com/2015-bag']
                product.get('color').should.equal '米白色'
                product.get('size').should.equal 'XL'
                product.get('description').should.equal '2015 年新款，限量 300 個。'
                @view.model.get('quantity').should.equal 2

              it 'updates the view with updated product attributes', ->
                @view.$('.order-line-item-preview .item-brand').text().should.equal 'A&F'
                @view.$('.order-line-item-preview .item-title').text().should.equal '2015 限量紀念包'
                @view.$('.order-line-item-preview .item-color').text().should.equal '米白色'
                @view.$('.order-line-item-preview .item-size').text().should.equal 'XL'
                @view.$('.order-line-item-preview .item-price').text().should.equal "單價：#{acct.formatMoney(100 * @order.get('exchange_rate'))}"
                @view.$('.order-line-item-preview .item-quantity').text().should.equal '數量：2 個'
                @view.$('.order-line-item-preview .item-subtotal').text().should.equal acct.formatMoney(2 * 100 * @order.get('exchange_rate'))

            else
              it 'sets the order notes with correct value', ->
                @view.model.get('notes').should.equal '多退少補'

              it 'updates the view with updated order line item attributes', ->
                @view.$('.item-price').text().should.equal acct.formatMoney(100 * @order.get('exchange_rate'))
                @view.$('.order-line-item-preview .item-subtotal').text().should.equal acct.formatMoney(100 * @order.get('exchange_rate'))

        xdescribe '#setupDirtyForm', -> undefined
        xdescribe '#setupRemoveDialog', -> undefined

  xdescribe 'existing item', -> undefined
