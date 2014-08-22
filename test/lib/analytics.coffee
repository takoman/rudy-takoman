_                 = require 'underscore'
rewire            = require 'rewire'
#rewiredAnalytics  = rewire '../../lib/analytics'
analytics         = require '../../lib/analytics'
sinon             = require 'sinon'
sd                = require('sharify').data
benv              = require 'benv'

describe 'analytics', ->

  beforeEach ->
    sd.GOOGLE_ANALYTICS_ID = 'goog that analytics'
    @gaStub = sinon.stub()
    analytics ga: @gaStub

  describe 'initialization function', ->

    it 'inits ga with the GOOGLE_ANALYTICS_ID', ->
      @gaStub.args[0][0].should.equal 'create'
      @gaStub.args[0][1].should.equal 'goog that analytics'

  describe '#trackPageview', ->

    it 'sends a google pageview without current user', ->
      analytics.trackPageview()
      @gaStub.args[1][0].should.equal 'send'
      @gaStub.args[1][1].should.equal 'pageview'

    it 'sends a google pageview for users other than admin', ->
      sd.CURRENT_USER = role: ['user', 'takoman']
      analytics.trackPageview()
      @gaStub.args[1][0].should.equal 'send'
      @gaStub.args[1][1].should.equal 'pageview'

    it 'does not track admins', ->
      sd.CURRENT_USER = role: ['takoman', 'admin']
      analytics.trackPageview()
      @gaStub.neverCalledWith('send', 'pageview').should.be.true

  describe '#registerCurrentUser', ->

    it 'registers regular user to google analytics', ->
      sd.CURRENT_USER = role: ['user', 'takoman']
      analytics.registerCurrentUser()
      @gaStub.args[1][0].should.equal 'set'
      @gaStub.args[1][1].should.equal 'dimension1'
      @gaStub.args[1][2].should.equal 'Logged In'

    it 'registers ananymous user to google analytics', ->
      sd.CURRENT_USER = null
      analytics.registerCurrentUser()
      @gaStub.args[1][0].should.equal 'set'
      @gaStub.args[1][1].should.equal 'dimension1'
      @gaStub.args[1][2].should.equal 'Logged Out'

    it 'does not register admins', ->
      sd.CURRENT_USER = role: ['takoman', 'admin']
      analytics.registerCurrentUser()
      @gaStub.neverCalledWith('set', 'dimension1').should.be.true
