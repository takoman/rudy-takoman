_           = require 'underscore'
Q           = require 'q'
sinon       = require 'sinon'
Backbone    = require 'backbone'
routes      = require '../routes'
CurrentUser = require '../../../models/current_user.coffee'

describe 'Dashboard routes', ->
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
      afterEach ->
        Backbone.sync.restore()

      describe 'as a regular user', ->
        beforeEach ->
          dfd = Q.defer()
          sinon.stub Backbone, 'sync', ->
            dfd.resolve()
            dfd.promise
          @req = { user: new CurrentUser() }

        it 'passes to the error handler', (done) ->
          next = sinon.stub()
          # TODO: figure out a better way to test promises.
          # Here since orderCreation returns a promise, so we can chain it
          # to test the results. It is not always the case.
          routes.orderCreation(@req, @res, next)
            .then =>
              @res.redirect.called.should.not.be.ok
              @res.render.called.should.not.be.ok
              next.calledWith('The logged in user is not a merchant').should.be.ok
              done()

      describe 'as a merchant', ->
        beforeEach ->
          dfd = Q.defer()
          sinon.stub Backbone, 'sync', ->
            Backbone.sync.args[0][1].add merchant_name: '天天開心賣家'
            dfd.resolve()
            dfd.promise
          @req = { user: new CurrentUser() }

        it 'renders the order creation page', (done) ->
          routes.orderCreation(@req, @res)
            .then =>
              @res.redirect.called.should.not.be.ok
              @res.render.args[0][0].should.equal 'order_creation'
              done()
