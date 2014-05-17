Backbone  = require 'backbone'
rewire    = require 'rewire'
sinon     = require 'sinon'

describe 'Takoman Passport methods', ->

  before ->
    @takomanPassport = rewire '../../../lib/middleware/takoman-passport.coffee'

  describe '#serializeUser', ->

    before ->
      @serializeUser = @takomanPassport.__get__ 'serializeUser'
      @takomanPassport.__set__ 'opts', { userKeys: ['id', 'foo'] }

    it 'only stores select data in the session', (done) ->
      model = new Backbone.Model({ id: 'takoman', foo: 'baz', bam: 'bop' })
      model.fetch = (opts) -> opts.success()
      @serializeUser model, (err, user) ->
        (user.foo?).should.be.ok
        (user.bam?).should.not.be.ok
        done()

  describe '#accessTokenCallback', ->

    before ->
      @accessTokenCallback = @takomanPassport.__get__ 'accessTokenCallback'

    it 'sets the user when no errors', (done) ->
      opts = @takomanPassport.__get__ 'opts'
      opts.CurrentUser = sinon.stub()
      opts.CurrentUser.returns { name: 'Takoman' }
      @accessTokenCallback((err, user) ->
        user.name.should.equal 'Takoman'
        done()
      )(null, body: { access_token: 'Takoman is the hero' } )


    it 'sends a false user when invalid email or password', (done) ->
      @accessTokenCallback((err, user, info) ->
        err?.should.not.be.ok
        user.should.not.be.ok
        info.should.include 'invalid email or password'
        done()
      )(null, error: 'invalid email or password')

    it 'sends error messages in an error object', (done) ->
      @accessTokenCallback((err) ->
        err.should.include 'Epic Fail'
        done()
      )(null, error: 'Epic Fail')
