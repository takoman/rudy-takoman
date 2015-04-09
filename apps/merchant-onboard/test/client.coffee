_           = require 'underscore'
sd          = require('sharify').data
benv        = require 'benv'
sinon       = require 'sinon'
rewire      = require 'rewire'
Backbone    = require 'backbone'
CurrentUser = require '../../../models/current_user'
{ resolve } = require 'path'

describe 'MerchantSignUpView', ->
  beforeEach (done) ->
    benv.setup =>
      benv.expose $: benv.require 'jquery'
      Backbone.$ = $
      sinon.stub Backbone, 'sync'
      benv.render resolve(__dirname, '../templates/new.jade'), { asset: (-> undefined), sd: {} }, =>
        { @MerchantSignUpView } = @mod = rewire '../client'
        done()

  afterEach ->
    Backbone.sync.restore()
    benv.teardown()

  describe '#initialize', ->
    describe 'with current user', ->
      beforeEach ->
        @CurrentUser = @mod.__get__ 'CurrentUser'
        sinon.stub @CurrentUser, 'orNull', -> new CurrentUser(
          _id: '1234'
          name: 'Tako Man'
          email: 'takoman@takoman.co'
        )
        @view = new @MerchantSignUpView el: $('body')

      afterEach ->
        @CurrentUser.orNull.restore()

      it 'initializes the current user', ->
        @view.user.get('_id').should.equal '1234'
        @view.user.get('name').should.equal 'Tako Man'
        @view.user.get('email').should.equal 'takoman@takoman.co'

    describe 'without current user', ->
      beforeEach ->
        @CurrentUser = @mod.__get__ 'CurrentUser'
        sinon.stub @CurrentUser, 'orNull', -> null
        @view = new @MerchantSignUpView el: $('body')

      afterEach ->
        @CurrentUser.orNull.restore()

      it 'initializes a null user', ->
        _.isNull(@view.user).should.be.ok

  describe '#createMerchant', ->
    beforeEach ->
      @CurrentUser = @mod.__get__ 'CurrentUser'
      sinon.stub @CurrentUser, 'orNull', -> new CurrentUser(_id: '1234')
      @view = new @MerchantSignUpView el: $('body')
      @view.$('form#merchant-sign-up [name="merchant-name"]').val '良心賣場'
      @view.$('form#merchant-sign-up [name="source-countries"][value="TW"]').prop 'checked', true
      @view.$('form#merchant-sign-up [name="source-countries"][value="US"]').prop 'checked', true
      @view.$('form#merchant-sign-up [name="source-countries"][value="JP"]').prop 'checked', true
      @view.$('form#merchant-sign-up').trigger 'submit'

    afterEach ->
      @CurrentUser.orNull.restore()

    it 'sends a POST request to /api/v1/merchants', ->
      Backbone.sync.args[0][1].url().should.endWith '/api/v1/merchants'

    it 'submits correct data', ->
      Backbone.sync.args[0][1].attributes.should.eql(
        user: '1234'
        merchant_name: '良心賣場'
        source_countries: ['TW', 'US', 'JP']
      )

    describe 'with successful creation', ->
      it 'redirects to /merchants/dashboard/profile', ->
        Backbone.sync.args[0][2].success()
        window.location.href.should.endWith '/merchants/dashboard/profile'

    describe 'with failed creation', ->
      it 'shows error messages', ->
        Backbone.sync.args[0][2].error { responseJSON: { message: 'Epic failure' } }
        @view.$('#merchant-sign-up-message').html().should.containEql 'Epic failure'
