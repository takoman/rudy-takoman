_ = require 'underscore'
Backbone = require 'backbone'
sinon = require 'sinon'
OrderLineItem = require '../../models/order_line_item.coffee'
OrderLineItems = require '../../collections/order_line_items.coffee'
fabricate = require '../helpers/fabricator.coffee'

describe 'OrderLineItems', ->
  beforeEach ->
    sinon.stub Backbone, 'sync'
    @orderLineItems = new OrderLineItems [fabricate 'order_line_item']

  afterEach ->
    Backbone.sync.restore()

  describe '.model', ->
    it 'news up the correct model', ->
      @orderLineItems.at(0).constructor.name.should.equal 'OrderLineItem'

  describe '.url', ->
    it 'returns the correct url', ->
      @orderLineItems.url.should.endWith '/api/v1/order_line_items'

  describe '#total', ->
    describe 'empty collection', ->
      beforeEach ->
        @orderLineItems = new OrderLineItems()

      it 'returns 0', ->
        @orderLineItems.total().should.equal 0

    describe 'with all valid types', ->
      beforeEach ->
        @orderLineItems = new OrderLineItems [
          fabricate 'order_line_item', type: 'product', quantity: 1, price: 5033
          fabricate 'order_line_item', type: 'commission', quantity: 1, price: 1500
          fabricate 'order_line_item', type: 'product', quantity: 3, price: 13050
          fabricate 'order_line_item', type: 'commission', quantity: 2, price: 2000
          fabricate 'order_line_item', type: 'shipping', quantity: 1, price: 7800
          fabricate 'order_line_item', type: 'shipping', quantity: 1, price: 13300
        ]

      it 'returns correct total', ->
        @orderLineItems.total().should.equal 70783

    describe 'with some invalid types', ->
      beforeEach ->
        @orderLineItems = new OrderLineItems [
          fabricate 'order_line_item', type: 'product', quantity: 1, price: 5033
          fabricate 'order_line_item', type: 'commission', quantity: 1, price: 1500
          fabricate 'order_line_item', type: 'product', quantity: 3, price: 13050
          fabricate 'order_line_item', type: 'commission', quantity: 2, price: 2000
          fabricate 'order_line_item', type: 'unknown', quantity: 99, price: 10000
          fabricate 'order_line_item', type: 'shipping', quantity: 1, price: 7800
          fabricate 'order_line_item', type: 'shipping', quantity: 1, price: 13300
          fabricate 'order_line_item', type: '', quantity: 99, price: 10000
          fabricate 'order_line_item', type: null, quantity: 99, price: 10000
        ]

      it 'returns correct total', ->
        @orderLineItems.total().should.equal 70783
