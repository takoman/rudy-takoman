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
        $.fn.waypoint = (@waypoint = sinon.stub())
        $.fn.css = (@css = sinon.stub())
        @view = new CheckoutHeaderView el: $('#checkout-header')
        done()

  afterEach ->
    benv.teardown()

  describe '#initialize', ->
    it 'Shoud set up waypoint with correct callback', ->
      @waypoint.calledOnce.should.be.ok
      callback = @waypoint.args[0][0]
      # args[0][0] means when the first time @waypoint got called, what the first argument is.
      # In our code, the first argument when we call waypoint is a callback function.
      callback('down')
      @css.calledOnce.should.be.ok
      _.last(@css.args)[0].should.eql 'background-color'
      # We usually want to see the arguments when last time a stubbed function got called.
      # A useful pattern is to use underscore function _.last()
      _.last(@css.args)[1].should.eql '#dddddd'
      callback('up')
      @css.calledTwice.should.be.ok
      _.last(@css.args)[0].should.eql 'background-color'
      _.last(@css.args)[1].should.eql '#FD5650'

    it 'Should set up waypoint with correct offset', ->
      @waypoint.calledOnce.should.be.ok
      @waypoint.args[0][1].should.eql { offset: -250 }
