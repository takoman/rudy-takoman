_           = require 'underscore'
sinon       = require 'sinon'
Backbone    = require 'backbone'
routes      = require '../routes'
CurrentUser = require '../../../models/current_user.coffee'

describe 'Dashboard routes', ->
  beforeEach ->
    @res = { render: sinon.stub(), redirect: sinon.stub(), locals: { sd: {} } }
    sinon.stub Backbone, 'sync'

  afterEach ->
    Backbone.sync.restore()

  describe '#orderCreation', ->
    describe 'logged out', ->
      beforeEach ->
        req = { user: undefined }
        routes.orderCreation req, @res

      it 'redirects to the log in page', ->
        @res.redirect.args[0][0].should.equal '/login'

    describe 'logged in', ->
      describe 'as a regular user', ->
        beforeEach ->
          req = { user: new CurrentUser() }
          routes.orderCreation req, @res

        xit 'renders the 404 page', ->
          undefined

      describe 'as a merchant', ->
        beforeEach ->
          req = { user: new CurrentUser() }
          routes.orderCreation req, @res

        it 'renders the order creation page', ->
          @res.redirect.called.should.not.be.ok
          @res.render.args[0][0].should.equal 'order_creation'

