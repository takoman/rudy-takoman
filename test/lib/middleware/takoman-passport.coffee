_         = require 'underscore'
Backbone  = require 'backbone'
rewire    = require 'rewire'
sinon     = require 'sinon'

describe 'Takoman Passport methods', ->

  before ->
    # Remember that every call of rewire() returns a new instance.
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
        _.isNull(err).should.be.ok
        user.should.not.be.ok
        info.should.include 'invalid email or password'
        done()
      )(null, body: { status: 'error', message: 'invalid email or password' })

    it 'sends error messages to error handler when unknown error', (done) ->
      @accessTokenCallback((err) ->
        err.should.include 'Epic Fail'
        done()
      )(null, body: { status: 'error', message: 'Epic Fail' })

    it 'sends error messages to error handler when errors other than 4xx, 5xx', (done) ->
      @accessTokenCallback((err) ->
        err.should.include 'error other than 4xx and 5xx'
        done()
      )('error other than 4xx and 5xx', body: {})

    context 'with a "no account linked" error', ->

      beforeEach ->
        @request = @takomanPassport.__get__ 'request'
        post = sinon.stub @request, 'post'
        post.returns set: (set = sinon.stub())
        set.returns send: (@send = sinon.stub())
        @send.returns end: (end = sinon.stub())
        @done = sinon.stub()
        @accessTokenCallback(@done, { name: 'foobar' })(
          null, body: { status: 'error', message: 'no account linked' }
        )
        @end = end.args[0][0]

      afterEach ->
        @request.post.restore()

      it 'creates a user', ->
        @request.post.args[0][0].should.include '/api/v1/user'

      it 'creates a user with params passed to accessTokenCallback', ->
        @send.args[0][0].should.eql { name: 'foobar' }

      it 'passes a custom error for our afterSocialSignup callback to redirect to login', ->
        @end null, body: { name: 'Takoman' }
        @done.args[0][0].message.should.equal 'takoman-passport: created user from social'

  describe '#facebookCallback', ->

    before ->
      @facebookCallback = @takomanPassport.__get__ 'facebookCallback'
      @takomanPassport.__set__ 'opts',
        API_URL: 'http://api.takoman.co'
        TAKOMAN_ID: 'takoman#1'
        TAKOMAN_SECRET: 'takoman999'

    context 'with logged in user', ->

      xit 'links a logged in user to his/her facebook account'

    context 'without a user', ->

      beforeEach ->
        @accessTokenCallback = sinon.stub()
        @takomanPassport.__set__ 'accessTokenCallback', @accessTokenCallback
        @request = @takomanPassport.__get__ 'request'
        @post = sinon.stub @request, 'post'
        @post.returns send: (@send = sinon.stub())
        @send.returns end: (end = sinon.stub())

      afterEach ->
        @request.post.restore()

      it 'calls API to trade Facebook OAuth token for XAuth token', ->
        @facebookCallback({}, 'facebook_token')
        @post.args[0][0].should.equal 'http://api.takoman.co/oauth2/access_token'
        @send.args[0][0].client_id.should.equal 'takoman#1'
        @send.args[0][0].client_secret.should.equal 'takoman999'
        @send.args[0][0].grant_type.should.equal 'oauth_token'
        @send.args[0][0].oauth_token.should.equal 'facebook_token'
        @send.args[0][0].oauth_provider.should.equal 'facebook'

      it 'logs in with the XAuth token obtained from the OAuth token', ->
        done = sinon.stub()
        @facebookCallback({}, 'facebook_token', 'refresh_token', {displayName: 'Hero'}, done)
        @accessTokenCallback.calledOnce.should.be.ok
        @accessTokenCallback.args[0][0].should.equal done
        @accessTokenCallback.args[0][1].oauth_token.should.equal 'facebook_token'
        @accessTokenCallback.args[0][1].provider.should.equal 'facebook'
        @accessTokenCallback.args[0][1].name.should.equal 'Hero'
