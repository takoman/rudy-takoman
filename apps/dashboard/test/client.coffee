_           = require 'underscore'
sd          = require('sharify').data
benv        = require 'benv'
sinon       = require 'sinon'
rewire      = require 'rewire'
Backbone    = require 'backbone'
{ resolve } = require 'path'
{ OrderFormView, OrderLineItemView } = require '../client'

describe 'OrderFormView', ->
  before (done) ->
    benv.setup =>
      benv.expose $: benv.require 'jquery'
      Backbone.$ = $
      done()

  after ->
    benv.teardown()

  beforeEach (done) ->
    sinon.stub Backbone, 'sync'
    benv.render resolve(__dirname, '../templates/order_creation.jade'), { asset: (->), sd: {} }, =>
      @view = new OrderFormView el: $('body')
      done()

  afterEach ->
    Backbone.sync.restore()

  describe '#initialize', ->
    it 'initializes an empty array for order line item views', ->
      @view.orderLineItems.should.eql []

  describe '#setExchangeRate', ->
    describe 'with empty exchange rate', ->
      it 'shows an error message', ->
        @view.setExchangeRate()
        @view.$('#currency-msg').text().should.equal '請輸入正確匯率'

    describe 'with non-number exchange rate', ->
      it 'shows an error message', ->
        @view.$('#exchange-rate').val '35 dollars'
        @view.setExchangeRate()
        @view.$('#currency-msg').text().should.equal '請輸入正確匯率'

    describe 'with valid exchange rate', ->
      it 'shows the exchange rate and currency info', ->
        @view.$('#currency-source').val 'USD'
        @view.$('#exchange-rate').val '30.50'
        @view.setExchangeRate()
        @view.$('#step1-block-2').text().should.equal '貨幣： USD對台幣匯率為：30.50'

  describe '#countTotal', ->
    describe 'without any order line items', ->
      beforeEach ->
        @view.countTotal()

      it 'calculates the total', ->
        @view.total.should.equal 0

      it 'shows NT 0 for all the types', ->
        @view.$('#product-total').text().should.equal ' NT 0'
        @view.$('#shipping-total').text().should.equal ' NT 0'
        @view.$('#commission-total').text().should.equal ' NT 0'

    describe 'with order line items', ->
      before ->
        sinon.stub OrderLineItemView.prototype, 'render'

      after ->
        OrderLineItemView.prototype.render.restore()

      beforeEach ->
        @view.orderLineItems = _.map [
          { type: 'product', twdprice: 150.00 },
          { type: 'product', twdprice: 50.00 },
          { type: 'shipping', twdprice: 5.00 },
          { type: 'shipping', twdprice: 10.00 },
          { type: 'commission', twdprice: 20.00 },
          { type: 'commission', twdprice: 40.00 },
          { type: 'unknown', twdprice: 400.00 }
        ], (i) -> v = new OrderLineItemView(type: i.type); v.twdprice = i.twdprice; v
        @view.countTotal()

      it 'calculates the total', ->
        @view.total.should.equal 275.00

      it 'shows the subtotal for each type', ->
        @view.$('#product-total').text().should.equal ' NT 200'
        @view.$('#shipping-total').text().should.equal ' NT 15'
        @view.$('#commission-total').text().should.equal ' NT 60'

  describe '#createOrder', ->
    xit 'submits the order creation request with correct line items data', ->
      undefined

  xdescribe 'view specs for clicking and adding line items and submission', ->
    # For example, render the page, enter exchange rate, click "next",
    # click "add a product", enter info, click "add shipping", enter info, ...
    # and click "save". Test if the submitted order contains the correct data.
    undefined
