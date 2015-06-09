_ = require 'underscore'
Backbone = require 'backbone'
sinon = require 'sinon'
InvoiceLineItem = require '../../models/invoice_line_item.coffee'
InvoiceLineItems = require '../../collections/invoice_line_items.coffee'
fabricate = require '../helpers/fabricator.coffee'

describe 'InvoiceLineItems', ->
  beforeEach ->
    sinon.stub Backbone, 'sync'
    @invoiceLineItems = new InvoiceLineItems [fabricate 'invoice_line_item']

  afterEach ->
    Backbone.sync.restore()

  describe '.model', ->
    it 'news up the correct model', ->
      @invoiceLineItems.at(0).constructor.name.should.equal 'InvoiceLineItem'

  describe '.url', ->
    it 'returns the correct url', ->
      @invoiceLineItems.url.should.endWith '/api/v1/invoice_line_items'

  describe '#total', ->
    describe 'empty collection', ->
      beforeEach ->
        @invoiceLineItems = new InvoiceLineItems()

      it 'returns 0', ->
        @invoiceLineItems.total().should.equal 0

    describe 'with all valid types', ->
      beforeEach ->
        @invoiceLineItems = new InvoiceLineItems [
          fabricate 'invoice_line_item', quantity: 1, price: 5033, order_line_item:
            fabricate 'order_line_item', type: 'product'
          fabricate 'invoice_line_item', quantity: 1, price: 1500, order_line_item:
            fabricate 'order_line_item', type: 'commission'
          fabricate 'invoice_line_item', quantity: 3, price: 13050, order_line_item:
            fabricate 'order_line_item', type: 'product'
          fabricate 'invoice_line_item', quantity: 2, price: 2000, order_line_item:
            fabricate 'order_line_item', type: 'commission'
          fabricate 'invoice_line_item', quantity: 1, price: 7800, order_line_item:
            fabricate 'order_line_item', type: 'shipping'
          fabricate 'invoice_line_item', quantity: 1, price: 13300, order_line_item:
            fabricate 'order_line_item', type: 'shipping'
        ]

      it 'returns correct total', ->
        @invoiceLineItems.total().should.equal 70783

    describe 'with some invalid types', ->
      beforeEach ->
        @invoiceLineItems = new InvoiceLineItems [
          fabricate 'invoice_line_item', quantity: 1, price: 5033, order_line_item:
            fabricate 'order_line_item', type: 'product'
          fabricate 'invoice_line_item', quantity: 1, price: 1500, order_line_item:
            fabricate 'order_line_item', type: 'commission'
          fabricate 'invoice_line_item', quantity: 3, price: 13050, order_line_item:
            fabricate 'order_line_item', type: 'product'
          fabricate 'invoice_line_item', quantity: 1, price: 13300, order_line_item:
            fabricate 'order_line_item', type: 'unknown'
          fabricate 'invoice_line_item', quantity: 2, price: 2000, order_line_item:
            fabricate 'order_line_item', type: 'commission'
          fabricate 'invoice_line_item', quantity: 1, price: 13300, order_line_item:
            fabricate 'order_line_item', type: 'random'
          fabricate 'invoice_line_item', quantity: 1, price: 7800, order_line_item:
            fabricate 'order_line_item', type: 'shipping'
          fabricate 'invoice_line_item', quantity: 1, price: 13300, order_line_item:
            fabricate 'order_line_item', type: 'shipping'
          fabricate 'invoice_line_item', quantity: 1, price: 13300, order_line_item:
            fabricate 'order_line_item', type: ''
          fabricate 'invoice_line_item', quantity: 1, price: 13300, order_line_item:
            fabricate 'order_line_item', type: null
        ]

      it 'returns correct total', ->
        @invoiceLineItems.total().should.equal 70783
