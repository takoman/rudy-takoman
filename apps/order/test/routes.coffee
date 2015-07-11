_           = require 'underscore'
Q           = require 'q'
sinon       = require 'sinon'
Backbone    = require 'backbone'
routes      = require '../routes'
CurrentUser = require '../../../models/current_user.coffee'
Merchant = require '../../../models/merchant.coffee'
Merchants = require '../../../collections/merchants.coffee'

describe 'Order routes', ->
  beforeEach ->
    @res = { render: sinon.stub(), redirect: sinon.stub(), locals: { sd: {} } }

  describe '#orderCreation', ->
    describe 'logged out', ->
      beforeEach ->
        req = { user: undefined }
        routes.orderCreation req, @res

      it 'redirects to the log in page', ->
        @res.redirect.args[0][0].should.equal '/login'

    describe 'logged in', ->
      beforeEach ->
        @sync = sinon.stub Backbone, 'sync'

      afterEach ->
        Backbone.sync.restore()

      describe 'as a regular user', ->
        beforeEach ->
          @merchantDfd = Q.defer()
          @sync.withArgs('read', new Merchants()).returns @merchantDfd.promise
          @req = { user: new CurrentUser() }

        it 'passes to the error handler', (done) ->
          next = sinon.stub()
          routes.orderCreation(@req, @res, next)
          @sync.args.length.should.equal 1
          @merchantDfd.resolve()
          _.defer =>
            @res.redirect.called.should.not.be.ok
            @res.render.called.should.not.be.ok
            next.calledWith('The logged in user is not a merchant').should.be.ok
            done()

      describe 'as a merchant', ->
        beforeEach ->
          @merchantDfd = Q.defer()
          @sync.withArgs('read', new Merchants()).returns @merchantDfd.promise
          @req = { user: new CurrentUser() }

        it 'renders the order creation page', (done) ->
          routes.orderCreation(@req, @res)
          @sync.args.length.should.equal 1
          @sync.args[0][1].add merchant_name: '天天開心賣家'
          @merchantDfd.resolve()
          _.defer =>
            @res.redirect.called.should.not.be.ok
            @res.render.args[0][0].should.equal 'index'
            done()
