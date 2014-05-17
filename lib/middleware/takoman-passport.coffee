#
# Uses [passport.js](http://passportjs.org/) to setup authentication with various
# providers like direct login with Rudy, or oauth signin with Facebook or Twitter.
#

_             = require 'underscore'
request       = require 'superagent'
express       = require 'express'
passport      = require 'passport'
LocalStrategy = require('passport-local').Strategy
qs            = require 'querystring'
{ parse }     = require 'url'

# Hoist the XAPP token out of a request and store it at the module level for
# the passport callbacks to access. (Seems like there should be a better way to access
# request-level data in the passport callbacks.)
takomanXappToken = null

# Default options
opts =
  loginPath   : '/login'
  signupPath  : '/signup'
  userKeys    : ['id', 'type', 'name', 'email', 'phone', 'lab_features', 'default_profile_id']

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
  passport.use new LocalStrategy { usernameField: 'email' }, takomanCallback

initApp = ->
  app.use passport.initialize()
  app.use passport.session()
  app.post opts.loginPath, localAuth
  app.post opts.signupPath, signup, passport.authenticate('local')
  app.use addLocals

#
# Use custom callback for local auth
#
# https://github.com/jaredhanson/passport/blob/master/lib/authenticator.js#L138-L168
#
localAuth = (req, res, next) ->
  passport.authenticate('local', (err, user, info) ->
    return next(err) if err
    return res.redirect(opts.loginPath) if not user

    # Since we are using custom callback, we have to establish a session
    # (by calling req.login()) and send a response.
    req.login(user, next) if user

    # else?
  )(req, res, next)

signup = (req, res, next) ->
  request.post(opts.TAKOMAN_URL + '/api/v1/user').send(
    name: req.body.name
    email: req.body.email
    password: req.body.password
    xapp_token: res.locals.takomanXappToken
  ).end onCreateUser(next)

onCreateUser = (next) ->
  (err, res) ->
    if res.status isnt 201
      errMsg = res.body.message
    else
      errMsg = err?.text
    if errMsg then next(errMsg) else next()

addLocals = (req, res, next) ->
  if req.user
    res.locals.user = req.user
    res.locals.sd?.CURRENT_USER = req.user.toJSON()
  next()

#
# Local strategy callback
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
takomanCallback = (username, password, done) ->
  request.get("#{opts.TAKOMAN_URL}/oauth2/access_token").query(
    client_id: opts.TAKOMAN_ID
    client_secret: opts.TAKOMAN_SECRET
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
  return (err, res) ->
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
serializeUser = (user, done) ->
  user.fetch
    success: ->
      keys = ['accessToken'].concat opts.userKeys
      done null, user.pick(keys)
    error: (m, e) -> done e.text

deserializeUser = (userData, done) ->
  done null, new opts.CurrentUser(userData)
