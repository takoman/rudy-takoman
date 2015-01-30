_ = require 'underscore'
benv = require 'benv'
Backbone = require 'backbone'
sinon = require 'sinon'
{ resolve } = require 'path'
CheckoutHeaderView = require '../view'

describe 'CheckoutHeaderView', ->
  beforeEach (done) ->
    benv.setup =>
      benv.expose
        $: benv.require 'jquery'
      Backbone.$ = $
      benv.render resolve(__dirname, '../mixin.jade'), {}, =>
        @el = $('#checkout-header')
        @el.waypoint = sinon.stub()
        @view = new CheckoutHeaderView el: $('#checkout-header')
        done()

  afterEach ->
    benv.teardown()

  describe '#initialize', ->
    it 'Shoud have background color #fd5650', ->
      @view.$block.css( "background-color" ).should.containEql '#fd5650'
