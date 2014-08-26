_                 = require 'underscore'
rewire            = require 'rewire'
rewiredAnalytics  = rewire '../../lib/analytics'
sinon             = require 'sinon'

describe 'analytics', ->

  beforeEach ->
    rewiredAnalytics.__set__ 'sd', GOOGLE_ANALYTICS_ID: 'goog that analytics'
    @gaStub = sinon.stub()
    rewiredAnalytics ga: @gaStub

  describe 'initialization function', ->

    it 'inits ga with the GOOGLE_ANALYTICS_ID', ->
      @gaStub.args[0][0].should.equal 'create'
      @gaStub.args[0][1].should.equal 'goog that analytics'

  describe '#trackPageview', ->

    beforeEach ->
      @sd = rewiredAnalytics.__get__ 'sd'
      # Reset the CURRENT_USER
      delete @sd.CURRENT_USER

    it 'sends a google pageview without current user', ->
      rewiredAnalytics.trackPageview()
      @gaStub.args[1][0].should.equal 'send'
      @gaStub.args[1][1].should.equal 'pageview'

    it 'sends a google pageview for users other than admin', ->
      @sd.CURRENT_USER = role: ['user', 'takoman']
      rewiredAnalytics.trackPageview()
      @gaStub.args[1][0].should.equal 'send'
      @gaStub.args[1][1].should.equal 'pageview'

    it 'does not track admins', ->
      @sd.CURRENT_USER = role: ['takoman', 'admin']
      rewiredAnalytics.trackPageview()
      @gaStub.neverCalledWith('send', 'pageview').should.be.true

  describe '#registerCurrentUser', ->

    beforeEach ->
      @sd = rewiredAnalytics.__get__ 'sd'
      delete @sd.CURRENT_USER

    it 'registers regular user to google rewiredAnalytics', ->
      @sd.CURRENT_USER = role: ['user', 'takoman']
      rewiredAnalytics.registerCurrentUser()
      @gaStub.args[1][0].should.equal 'set'
      @gaStub.args[1][1].should.equal 'dimension1'
      @gaStub.args[1][2].should.equal 'Logged In'

    it 'registers ananymous user to google rewiredAnalytics', ->
      rewiredAnalytics.registerCurrentUser()
      @gaStub.args[1][0].should.equal 'set'
      @gaStub.args[1][1].should.equal 'dimension1'
      @gaStub.args[1][2].should.equal 'Logged Out'

    it 'does not register admins', ->
      @sd.CURRENT_USER = role: ['takoman', 'admin']
      rewiredAnalytics.registerCurrentUser()
      @gaStub.neverCalledWith('set', 'dimension1').should.be.true
