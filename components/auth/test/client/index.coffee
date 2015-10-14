_           = require 'underscore'
Q           = require 'q'
sd          = require('sharify').data
benv        = require 'benv'
sinon       = require 'sinon'
rewire      = require 'rewire'
Backbone    = require 'backbone'
AuthView    = require '../../client/index.coffee'
{ resolve } = require 'path'
template    = require('jade').compileFile require.resolve '../../templates/index.jade'

describe 'AuthView', ->
  beforeEach (done) ->
    benv.setup =>
      benv.expose
        $: benv.require 'jquery'
        location: reload: sinon.stub()
      Backbone.$ = $
      @sync = sinon.stub Backbone, 'sync'
      $('body').html template()
      new AuthView el: $('body')
      done()

  afterEach ->
    Backbone.sync.restore()
    benv.teardown()

  describe 'login', ->
    beforeEach ->
      @loginDfd = Q.defer()
      @sync.withArgs('create').returns @loginDfd.promise
      $('#form-login input[name="email"]').val 'steve@takoman.co'
      $('#form-login input[name="password"]').val 'password'
      $('#form-login').submit()

    it 'makes the POST request properly', ->
      Backbone.sync.called.should.be.ok
      Backbone.sync.args[0][0].should.equal 'create'
      Backbone.sync.args[0][1].attributes.should.containEql
        email: 'steve@takoman.co'
        password: 'password'
      Backbone.sync.args[0][1].url().should.equal '/users/login'

    it 'reloads the page if succeeded', (done) ->
      @loginDfd.resolve()
      _.defer ->
        location.reload.called.should.be.ok
        done()

    it 'shows the error message if failed', (done) ->
      @loginDfd.reject responseText: JSON.stringify message: 'you are not allowed'
      _.defer ->
        location.reload.called.should.not.be.ok
        $('.alert').html().should.equal 'you are not allowed'
        done()

  describe 'signup', ->
    beforeEach ->
      @signupDfd = Q.defer()
      @sync.withArgs('create').returns @signupDfd.promise
      $('#form-signup input[name="name"]').val 'Steve Jobs'
      $('#form-signup input[name="email"]').val 'steve@takoman.co'
      $('#form-signup input[name="password"]').val 'password'
      $('#form-signup').submit()

    it 'makes the POST request properly', ->
      Backbone.sync.called.should.be.ok
      Backbone.sync.args[0][0].should.equal 'create'
      Backbone.sync.args[0][1].attributes.should.containEql
        email: 'steve@takoman.co'
        password: 'password'
      Backbone.sync.args[0][1].url().should.equal '/users/signup'

    it 'reloads the page if succeeded', (done) ->
      @signupDfd.resolve()
      _.defer ->
        location.reload.called.should.not.be.ok
        location.href.should.equal '/'
        done()

    it 'shows the error message if failed', (done) ->
      @signupDfd.reject responseText: JSON.stringify message: 'you are not allowed'
      _.defer ->
        location.reload.called.should.not.be.ok
        $('.alert').html().should.equal 'you are not allowed'
        done()
