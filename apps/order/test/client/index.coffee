_           = require 'underscore'
sd          = require('sharify').data
acct        = require 'accounting'
benv        = require 'benv'
sinon       = require 'sinon'
rewire      = require 'rewire'
Backbone    = require 'backbone'
{ resolve } = require 'path'
{ OrderFormView } = require '../../client/index'
Order = require "../../../../models/order.coffee"
OrderLineItem = require "../../../../models/order_line_item.coffee"
OrderLineItems = require "../../../../collections/order_line_items.coffee"

describe 'OrderFormView', ->
  before (done) ->
    benv.setup ->
      benv.expose $: benv.require 'jquery'
      Backbone.$ = $
      done()

  after ->
    benv.teardown()

  beforeEach ->
    sinon.stub Backbone, 'sync'

  afterEach ->
    Backbone.sync.restore()

  describe 'new order', ->
    beforeEach (done) ->
      @order = new Order()
      @orderLineItems = new OrderLineItems()
      benv.render resolve(__dirname, '../../templates/index.jade'),
        asset: (-> undefined)
        sd: {}
        _: _
        acct: acct
        order: @order
        orderLineItems: @orderLineItems
      , =>
        @view = new OrderFormView
          el: $('body')
          order: @order
          orderLineItems: @orderLineItems
        done()

    describe '#initialize', ->
      it 'assigns the @order and @orderLineItems', ->
        @view.order.should.equal @order
        @view.orderLineItems.should.equal @orderLineItems

    describe '#updateTotal', ->
      describe 'without any order line items', ->
        beforeEach ->
          @view.updateTotal()

        it 'shows 0 for all the types', ->
          @view.$('#order-product-total').text().should.equal acct.formatMoney 0
          @view.$('#order-shipping-total').text().should.equal acct.formatMoney 0
          @view.$('#order-commission-total').text().should.equal acct.formatMoney 0
          @view.$('#order-total').text().should.equal acct.formatMoney 0

      describe 'with order line items', ->
        beforeEach ->
          _.each [
            { type: 'product', price: 150.00, quantity: 1 },
            { type: 'product', price: 50.00, quantity: 2 },
            { type: 'shipping', price: 5.00, quantity: 1 },
            { type: 'shipping', price: 10.00, quantity: 1 },
            { type: 'commission', price: 20.00, quantity: 1 },
            { type: 'commission', price: 40.00, quantity: 1 },
            { type: 'unknown', price: 400.00, quantity: 99 }
          ], (item) => @view.orderLineItems.add new OrderLineItem item
          @view.updateTotal()

        it 'shows the subtotal for each type', ->
          @view.$('#order-product-total').text().should.equal acct.formatMoney 250
          @view.$('#order-shipping-total').text().should.equal acct.formatMoney 15
          @view.$('#order-commission-total').text().should.equal acct.formatMoney 60
          @view.$('#order-total').text().should.equal acct.formatMoney 325

    describe '#saveOrderAndRelated', ->
      beforeEach ->
        @view.order.set { exchange_rate: 35.5, currency_source: 'UTD' }
        @items = [
          { type: 'product', price: 150.00, quantity: 1 },
          { type: 'product', price: 50.00, quantity: 2 },
          { type: 'shipping', price: 5.00, quantity: 1 },
          { type: 'commission', price: 40.00, quantity: 1 },
          { type: 'unknown', price: 400.00, quantity: 99 }
        ]
        _.each @items, (item) => @view.orderLineItems.add new OrderLineItem item
        @products = [
          {
            title: 'A&F 超帥氣夾克'
            brand: 'A&F'
            images: [{ original: 'https://a.b.com/a.jpg' }]
            urls: ['http://www.abercrombie.com/henderson-lake-hooded-jacket?ofp=true']
            description: 'A&F 超帥氣夾克'
          },
          {
            title: 'Kate Spade 細長夾'
            brand: 'Kate Spade New York'
            images: [{ original: 'https://kate.spake.com/wallet.jpg' }]
            urls: ['http://kate.spade.com/wallet-20013']
            description: '亮皮已包裝'
          }
        ]
        @view.orderLineItems.at(0).related().product.set @products[0]
        @view.orderLineItems.at(1).related().product.set @products[1]
        @view.saveOrderAndRelated()

      xit 'submits the order creation request', (done) -> undefined
