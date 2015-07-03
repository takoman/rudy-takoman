_           = require 'underscore'
Q           = require 'q'
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
Merchant = require "../../../../models/merchant.coffee"

describe 'OrderFormView', ->
  before (done) ->
    benv.setup ->
      benv.expose $: benv.require 'jquery'
      # benv.expose() exposes variables to the "global" object, instead of
      # the "window". Let's do it ourselves to make requiring waypoints work.
      window.$ = window.jQuery = $
      # Then we have to expose Waypoint to the global space as well.
      benv.expose Waypoint: benv.require('waypoints/lib/jquery.waypoints.min.js', 'Waypoint')
      require 'waypoints/lib/shortcuts/sticky.min.js'
      Backbone.$ = $
      done()

  after ->
    benv.teardown()

  beforeEach ->
    @sync = sinon.stub Backbone, 'sync'

  afterEach ->
    Backbone.sync.restore()

  describe 'new order', ->
    beforeEach (done) ->
      @order = new Order()
      @orderLineItems = new OrderLineItems()
      @merchant = new Merchant()
      benv.render resolve(__dirname, '../../templates/index.jade'),
        asset: (-> undefined)
        sd: {}
        _: _
        acct: acct
        order: @order
        orderLineItems: @orderLineItems
        merchant: @merchant
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

        [@orderDfd, @npLineItemDfd, @productDfd, @pLineItemDfd] = _.map [1..4], -> Q.defer()
        @sync.withArgs('create', @view.order).returns @orderDfd.promise
        _.each @view.orderLineItems.last(3), (item) =>
          @sync.withArgs('create', item).returns @npLineItemDfd.promise
        _.each @view.orderLineItems.first(2), (item) =>
          @sync.withArgs('create', item).returns @pLineItemDfd.promise
        @sync.withArgs('create', @view.orderLineItems.at(0).related().product).returns @productDfd.promise
        @sync.withArgs('create', @view.orderLineItems.at(1).related().product).returns @productDfd.promise
        @view.saveOrderAndRelated()

      it 'submits the order creation request', (done) ->
        # https://github.com/kriskowal/q/issues/274
        _.defer =>
          Backbone.sync.args.length.should.equal 1
          Backbone.sync.args[0][0].should.equal 'create'
          Backbone.sync.args[0][1].should.equal @view.order
          Backbone.sync.args[0][1].url().should.endWith '/api/v1/orders'
          @orderDfd.resolve()
          _.defer =>
            Backbone.sync.args.length.should.equal 6
            _.each [1..5], (i) -> Backbone.sync.args[i][0].should.equal 'create'
            Backbone.sync.args[1][1].should.eql @view.orderLineItems.at(2)
            Backbone.sync.args[2][1].should.eql @view.orderLineItems.at(3)
            Backbone.sync.args[3][1].should.eql @view.orderLineItems.at(4)
            Backbone.sync.args[4][1].should.eql @view.orderLineItems.at(0).related().product
            Backbone.sync.args[5][1].should.eql @view.orderLineItems.at(1).related().product
            @npLineItemDfd.resolve()
            @productDfd.resolve()
            _.defer =>
              Backbone.sync.args.length.should.equal 8
              _.each [6, 7], (i) -> Backbone.sync.args[i][0].should.equal 'create'
              Backbone.sync.args[6][1].should.eql @view.orderLineItems.at(0)
              Backbone.sync.args[7][1].should.eql @view.orderLineItems.at(1)
              done()

      it 'shows the success message if everything succeeds', (done) ->
        _.defer =>
          @orderDfd.resolve()
          _.defer =>
            @npLineItemDfd.resolve()
            @productDfd.resolve()
            _.defer =>
              @pLineItemDfd.resolve()
              _.defer =>
                @view.$('.order-edit-message').text().should.equal '訂單儲存成功！'
                done()

      it 'shows the error message if something goes wrong', (done) ->
        _.defer =>
          @orderDfd.resolve()
          _.defer =>
            @npLineItemDfd.resolve()
            # This should reject immediately without creating its
            # corresponding order line item.
            @productDfd.reject({responseJSON: message: 'godzilla invasion'})
            _.defer =>
              @view.$('.order-edit-message').text().should.equal(
                '訂單儲存失敗 (Godzilla invasion)。請再試一次或聯絡我們。')
              done()
