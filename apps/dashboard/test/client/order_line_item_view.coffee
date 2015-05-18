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
    OrderLineItemView = benv.requireWithJadeify(
      resolve(__dirname, '../../client/order_line_item_view'),
      ['orderLineItemTemplate']
    )
    @view = new OrderLineItemView
      type: 'product'
      order: new Order fabricate('order')
      model: new OrderLineItem()
    done()

  afterEach ->
    Backbone.sync.restore()

  describe '#initialize', ->
    it 'initializes the html of the view properly', ->
      @view.$('[name="currency-source"]').length.should.equal 2
      @view.$('[name="currency-source"]:checked').val().should.equal 'USD'
