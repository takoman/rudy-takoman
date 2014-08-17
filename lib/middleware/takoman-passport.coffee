#
# Uses [passport.js](http://passportjs.org/) to setup authentication with various
# providers like direct login with Rudy, or oauth signin with Facebook or Twitter.
#

_           = require 'underscore'
request     = require 'superagent'
express     = require 'express'
passport    = require 'passport'
qs          = require 'querystring'
{ parse }   = require 'url'
LocalStrategy     = require('passport-local').Strategy
FacebookStrategy  = require('passport-facebook').Strategy

# Hoist the XAPP token out of a request and store it at the module level for
# the passport callbacks to access. (Seems like there should be a better way to access
# request-level data in the passport callbacks.)
takomanXappToken = null

# Default options
opts =
  loginPath             : '/users/login'
  signupPath            : '/users/signup'
  facebookPath          : '/users/auth/facebook'
  facebookCallbackPath  : '/users/auth/facebook/callback'
  userKeys : ['id', 'type', 'name', 'email', 'phone', 'default_profile_id']

#
# Main function that overrides/injects any options, sets up passport, sets up an app to
# handle routing and injecting locals, and returns that app to be mounted as middleware.
#
module.exports = (options) =>
  module.exports.options = _.extend opts, options
  initPassport()
  initApp()
  app

#
# Setup the mounted app that routes signup/login and injects necessary locals.
#
module.exports.app = app = express()

#
# Setup passport.
#
initPassport = ->
  passport.serializeUser serializeUser
  passport.deserializeUser deserializeUser
  passport.use new LocalStrategy { usernameField: 'email' }, localCallback
  passport.use new FacebookStrategy
    clientID: opts.FACEBOOK_ID
    clientSecret: opts.FACEBOOK_SECRET
    callbackURL: "#{opts.APP_URL}#{opts.facebookCallbackPath}"
    passReqToCallback: true
  , facebookCallback

initApp = ->
  app.use passport.initialize()
  app.use passport.session()
  app.post opts.loginPath, localAuth
  app.post opts.signupPath, signup, localAuth
  app.get opts.facebookPath, socialAuth('facebook')
  app.get opts.facebookCallbackPath, socialAuth('facebook'), afterSocialSignup('facebook')
  app.use addLocals
  app.use errorHandler

errorHandler = (err, req, res, next) ->
  res.send 400, err

#
# Authenticate a user with the local strategy we specified. Use custom
# callback to process the auth results manually.
# https://github.com/jaredhanson/passport/blob/master/lib/authenticator.js#L138-L168
#
localAuth = (req, res, next) ->
  # TODO If the user has already logged in...
  # next() if req.user?
  passport.authenticate('local', (err, user, info) ->
    # Severe errors
    return next(err) if err

    # Successful login
    # Since we are using custom callback, we have to establish a session
    # (by calling req.login()) and send a response.
    return req.login(user, next) if user

    # Invalid login
    next( status: "error", message: info )
  )(req, res, next)

signup = (req, res, next) ->
  request
    .post("#{opts.API_URL}/api/v1/users")
    .set('X-XAPP-TOKEN', res.locals.takomanXappToken)
    .send(
      name: req.body.name
      email: req.body.email
      password: req.body.password
    ).end onCreateUser(next)

#
# Callback of submitting a user create request
# If succeed, it will proceed to the next middleware, usually log in
# automatically. If failed, it will go to error handling middlewares.
#
onCreateUser = (next) ->
  (err, res) ->
    return next(err) if err
    return next({ status: "error", message: res.body.message }) if res.status isnt 201
    next()

#
# Use passport.authenticate() as route middleware to authenticate the
# request.  The first step in Facebook authentication will involve
# redirecting the user to facebook.com. After authorization, Facebook will
# redirect the user back to this application at `opts.facebookCallbackPath`.
#
socialAuth = (provider) ->
  (req, res, next) ->
    takomanXappToken = res.locals.takomanXappToken if res.locals.takomanXappToken
    passport.authenticate(provider,
      callbackURL: "#{opts.APP_URL}#{opts[provider + 'CallbackPath']}?#{qs.stringify req.query}"
      scope: 'email'
    )(req, res, next)

#
# Error handling middleware to intercept user creation from social.
#
afterSocialSignup = (provider) ->
  (err, req, res, next) ->
    return next(err) unless err.message is 'takoman-passport: created user from social'

    querystring = qs.stringify _.omit(req.query, 'code', 'oauth_token', 'oauth_verifier')
    url = "#{opts.facebookPath}?#{querystring}"
    res.redirect url

addLocals = (req, res, next) ->
  if req.user
    res.locals.user = req.user
    # so we can access user date, e.g. access token, client and server
    res.locals.sd?.CURRENT_USER = req.user.toJSON()
  next()

#
# Local strategy callback to check the credentials
#
# After checking the credentials with `username` and `password`, call the
# `done` callback supplying a `user`, which should be set to `false` if the
# credentials are not valid. If an exception occured, `err` should be set.
#
# Examples:
#   done(err)         # an exception occured
#   done(null, false) # the credentials are not valid
#   done(null, user)  # success
#
# https://github.com/jaredhanson/passport-local/blob/master/lib/strategy.js#L9-L41
#
localCallback = (username, password, done) ->
  request.post("#{opts.API_URL}/oauth2/access_token").send(
    client_id: opts.TAKOMAN_ID
    client_secret: opts.TAKOMAN_SECRET
    grant_type: 'credentials'
    email: username
    password: password
  ).end accessTokenCallback(done)

#
# Returns the callback function for the superagent request object.
# Note that a 4xx or 5xx response is not considered an error, so we have to
# check `res.error` and `res.status` and other response properties.
# http://visionmedia.github.io/superagent/#error-handling
#
accessTokenCallback = (done, params) ->
  (err, res) ->
    # Catch the various forms of error takoman could encounter
    error = res.body.message if res.body.status is 'error'
    error ?= err

    # If there are no errors, create the user from the access token
    unless error
      return done(null, new opts.CurrentUser(accessToken: res.body.access_token))

    # For social auth, if there's no user linked to this account, create the
    # user via /users endpoint. Then pass a custom error so our signup
    # middleware can catch it, login, and move on.
    if error.match? 'no account linked'
      request
        .post("#{opts.API_URL}/api/v1/users")
        .set('X-XAPP-TOKEN', takomanXappToken)
        .send(params)
        .end (err, res) ->
          if res.status isnt 201
            error = res.body.message
          else
            error = err?.text
          return done(error or { message: 'takoman-passport: created user from social' })

    # Invalid email or password
    else if error.match? 'invalid email or password'
      return done(null, false, error)

    # Other errors
    else
      return done(error)

#
# Facebook will send back the token and profile, and the request
#
facebookCallback = (req, accessToken, refreshToken, profile, done) ->
  # if a logged in user visiting the facebook auth route?
  if req.user
    # TODO link the user to its facebook account
  else
    # Login using an XAuth Token obtained from a User's OAuth Token
    request.post("#{opts.API_URL}/oauth2/access_token").send(
      client_id: opts.TAKOMAN_ID
      client_secret: opts.TAKOMAN_SECRET
      grant_type: 'oauth_token'
      oauth_token: accessToken
      oauth_provider: 'facebook'
    ).end accessTokenCallback(done,
      oauth_token: accessToken
      provider: 'facebook'
      name: profile?.displayName
    )

#
# Serialize user by fetching and caching user data in the session.
#
# To support persistent login sessions, Passport needs to be able to
# serialize users into and deserialize users out of the session.  Typically,
# this will be as simple as storing the user ID when serializing, and finding
# the user by ID when deserializing.
#
serializeUser = (user, done) ->
  user.fetch
    success: ->
      keys = ['accessToken'].concat opts.userKeys
      done null, user.pick(keys)
    error: (m, e) -> done e.text

deserializeUser = (userData, done) ->
  done null, new opts.CurrentUser(userData)
