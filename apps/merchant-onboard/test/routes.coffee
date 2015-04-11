_           = require 'underscore'
sinon       = require 'sinon'
Backbone    = require 'backbone'
routes      = require '../routes'
CurrentUser = require '../../../models/current_user.coffee'

describe 'Merchant onboard routes', ->
  beforeEach ->
    @res = { render: sinon.stub(), redirect: sinon.stub(), locals: { sd: {} } }
    sinon.stub Backbone, 'sync'

  afterEach ->
    Backbone.sync.restore()

  describe '#new', ->
    describe 'logged out', ->
      beforeEach ->
        req = { user: undefined }
        routes.new req, @res

      it 'redirects to the log in page', ->
        @res.redirect.args[0][0].should.equal '/login'

    describe 'logged in', ->
      beforeEach ->
        req = { user: new CurrentUser() }
        routes.new req, @res

      it 'renders the merchant sign up page', ->
        @res.redirect.called.should.not.be.ok
        @res.render.args[0][0].should.equal 'new'
