_           = require 'underscore'
sd          = require('sharify').data
benv        = require 'benv'
sinon       = require 'sinon'
rewire      = require 'rewire'
Backbone    = require 'backbone'
fabricate   = require '../../../../test/helpers/fabricator.coffee'
OrderLineItem = require "../../../../models/order_line_item.coffee"
Order = require "../../../../models/order.coffee"
{ resolve } = require 'path'
OrderLineItemView = benv.requireWithJadeify(
  resolve(__dirname, '../../client/order_line_item_view'),
  ['orderLineItemTemplate']
)
OrderLineItemView.__set__ 'UploadForm', sinon.stub()

describe 'OrderFormView', ->
  before (done) ->
    benv.setup ->
      benv.expose $: benv.require 'jquery'
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
            @view.$('[name="currency-source"]:checked').val().should.equal 'USD'
            @view.$('[name="price"]').val().should.equal '0'

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
          else
            it 'renders a hidden quantity input with value set to 1', ->
              @view.$('[name="quantity"][type="hidden"]').length.should.equal 1
              @view.$('[name="quantity"][type="hidden"]').val().should.equal '1'

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

            it 'updates the view reflecting the new exchange rate', ->
              @view.$('[name="price"]').val().should.equal '100'
              @view.$('[name="currency-source"]:checked').val().should.equal 'USD'
              @view.$('.subtotal-message').text().should.containEql "#{100 * @order.get('exchange_rate')}"

            it 'stores the new exchange rate in @oldFXRate', ->
              @view.oldFXRate.should.equal 60

          describe 'currency source changed', ->
            it 'updates the view with the updated currency', ->
              @order.set 'currency_source', 'JPY'
              @view.$('[name="currency-source"]:checked').val().should.equal 'JPY'

        describe '#save', ->
          beforeEach ->
            @view.$('[name="currency-source"][value="USD"]').prop('checked', true)
            @view.$('[name="price"]').val '100'

            if type is 'product'
              @view.$('[name="quantity"]').val '2'
              @view.$('[name="title"]').val '2015 限量紀念包'
              @view.$('[name="brand"]').val 'A&F'
              @view.$('[name="url"]').val 'http://af.com/2015-bag'
              @view.$('[name="images"]').val 'http://af.com/2015-bag.jpg'
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
              @view.$('.order-line-item-preview .item-price').text().should.equal "#{100 * @order.get('exchange_rate')}"
              @view.$('.order-line-item-preview .item-quantity').text().should.equal '2'
              @view.$('.order-line-item-preview .item-subtotal').text().should.equal "#{2 * 100 * @order.get('exchange_rate')}"

          else
            it 'sets the order notes with correct value', ->
              @view.model.get('notes').should.equal '多退少補'

            it 'updates the view with updated order line item attributes', ->
              @view.$('.item-price').text().should.equal "#{100 * @order.get('exchange_rate')}"
              @view.$('.order-line-item-preview .item-subtotal').text().should.equal "#{100 * @order.get('exchange_rate')}"

  xdescribe 'existing item', -> undefined
