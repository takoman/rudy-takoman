_                 = require 'underscore'
Q                 = require 'q'
sinon             = require 'sinon'
Backbone          = require 'backbone'
routes            = require '../routes'
Invoice           = require '../../../models/invoice.coffee'
InvoiceLineItems  = require '../../../collections/invoice_line_items.coffee'

describe 'Invoice routes', ->
  beforeEach ->
    @res = { render: sinon.stub(), locals: { sd: {} } }
    @next = sinon.stub()

  describe '#index', ->
    describe 'without access key', ->
      beforeEach ->
        req = { query: {} }
        routes.index req, @res, @next

      it 'calls next()', ->
        @next.calledOnce.should.be.ok

    xdescribe 'with access key', -> undefined

  describe '#shipping', ->
    describe 'without access key', ->
      beforeEach ->
        req = { query: {}, params: {} }
        routes.shipping req, @res, @next

      it 'calls next()', ->
        @next.calledOnce.should.be.ok

    xdescribe 'with access key', -> undefined

  describe '#payment', ->
    describe 'without access key', ->
      beforeEach ->
        req = { query: {}, params: {} }
        routes.payment req, @res, @next

      it 'calls next()', ->
        @next.calledOnce.should.be.ok

    xdescribe 'with access key', -> undefined
