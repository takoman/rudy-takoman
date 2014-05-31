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

# Hoist the XAPP token out of a request and store it at the module level for
# the passport callbacks to access. (Seems like there should be a better way to access
# request-level data in the passport callbacks.)
takomanXappToken = null

# Default options
opts =
  loginPath             : '/users/login'
  signupPath            : '/users/signup'
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

initApp = ->
  app.use passport.initialize()
  app.use passport.session()
  app.post opts.loginPath, localAuth, afterLocalAuth
  app.post opts.signupPath, signup, passport.authenticate('local'), afterLocalAuth
  app.use addLocals

#
# Authenticate a user with the local strategy we specified. Use custom
# callback to process the auth results manually.
# https://github.com/jaredhanson/passport/blob/master/lib/authenticator.js#L138-L168
#
# TODO Consider just calling passport.authenticate('local'), if we don't need
# a custom callback here.
#
localAuth = (req, res, next) ->
  passport.authenticate('local', (err, user, info) ->
    return next(err) if err
    # Since we are using custom callback, we have to establish a session
    # (by calling req.login()) and send a response.
    return req.login(user, next) if user

    res.authError = info; next()
  )(req, res, next)

afterLocalAuth = (req, res, next) ->
  if res.authError
    res.send 403, { success: false, error: res.authError }
  else if req.xhr and req.user?
    res.send { success: true, user: req.user.toJSON() }
  else if req.xhr and not req.user?
    res.send { success: false, error: "missing user" }
  else
    next()

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
    # Eve will return 200 on validation errors, so we have to check the
    # response manually.
    # http://python-eve.org/features.html#data-validation
    # May need to change it if we change the interface of error responses.
    # https://github.com/takoman/santa/issues/30
    if res.status is 200 and res.body._status is 'ERR'
      error = res.body._issues
    else if res.status isnt 201
      error = res.text
    else
      error = err?.text
    if error then next(error) else next()

addLocals = (req, res, next) ->
  if req.user
    res.locals.user = req.user
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
    error = res.error if res.error?
    error ?= err

    # If there are no errors, create the user from the access token
    unless error
      return done(null, new opts.CurrentUser(accessToken: res.body.access_token))

    # Invalid email or password
    if error.match? 'invalid email or password'
      return done(null, false, error)

    # Other errors
    else
      return done(error)

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
