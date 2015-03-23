#
# Sets up intial project settings, middleware, mounted apps, and
# global configuration such as overriding Backbone.sync and
# populating sharify data
#

{ API_URL, APP_URL, NODE_ENV, TAKOMAN_ID, TAKOMAN_SECRET, COOKIE_DOMAIN, CDN_URL,
  SESSION_SECRET, SESSION_COOKIE_KEY, SESSION_COOKIE_MAX_AGE, FACEBOOK_ID,
  FACEBOOK_SECRET, GOOGLE_ANALYTICS_ID, SENTRY_DSN, SENTRY_PUBLIC_DSN } = config = require "../config"
_                     = require 'underscore'
express               = require 'express'
Backbone              = require 'backbone'
sharify               = require 'sharify'
path                  = require 'path'
bodyParser            = require 'body-parser'
cookieParser          = require 'cookie-parser'
session               = require 'cookie-session'
logger                = require 'morgan'
raven                 = require 'raven'
bucketAssets          = require 'bucket-assets'
localsMiddleware      = require './middleware/locals'
takomanPassport       = require './middleware/takoman-passport'
takomanXappMiddlware  = require './middleware/takoman-xapp-middleware'

# Inject some constant data into sharify
sharify.data =
  API_URL: API_URL
  APP_URL: APP_URL
  JS_EXT: (if "production" is NODE_ENV then ".min.js" else ".js")
  CSS_EXT: (if "production" is NODE_ENV then ".min.css" else ".css")
  CDN_URL: CDN_URL
  GOOGLE_ANALYTICS_ID: GOOGLE_ANALYTICS_ID
  SENTRY_PUBLIC_DSN: SENTRY_PUBLIC_DSN

# CurrentUser must be defined after setting sharify.data
CurrentUser = require '../models/current_user'

module.exports = (app) ->

  # Override Backbone to use server-side sync
  Backbone.sync = require "backbone-super-sync"
  # Set some headers for the santa API
  Backbone.sync.editRequest = (req) -> req.set
    'User-Agent'    : 'takoman'
    'X-XAPP-TOKEN'  : takomanXappMiddlware.token

  # Mount sharify
  app.use sharify

  # Development only
  if "development" is NODE_ENV
    # Compile assets on request in development
    app.use require("stylus").middleware
      src: path.resolve(__dirname, "../")
      dest: path.resolve(__dirname, "../public")
    app.use require("browserify-dev-middleware")
      src: path.resolve(__dirname, "../")
      transforms: [require("jadeify"), require('caching-coffeeify')]

  # Test only
  if "test" is NODE_ENV
    # Mount fake API server
    app.use "/__api", require("../test/helpers/integration.coffee").api

  # Setup Takoman XAPP & Passport middleware for authentication along with the
  # body/cookie parsing middleware needed for that.
  app.use takomanXappMiddlware(
    apiUrl: API_URL
    clientId: TAKOMAN_ID
    clientSecret: TAKOMAN_SECRET
  ) unless 'test' is NODE_ENV
  app.use bodyParser()
  app.use cookieParser()
  app.use session
    domain: COOKIE_DOMAIN
    secret: SESSION_SECRET
    key   : SESSION_COOKIE_KEY
    maxage: SESSION_COOKIE_MAX_AGE # For mobile safari to keep cookies after relaunch
  app.use takomanPassport _.extend config, { CurrentUser: CurrentUser }

  # General helpers and express middleware
  app.use bucketAssets()
  app.use localsMiddleware
  app.use logger('dev')

  # Mount apps
  app.use require "../apps/commits"
  app.use require "../apps/auth"
  app.use require "../apps/profile"
  app.use require "../apps/order"

  # Route to ping for system up
  app.get '/system/up', (req, res) ->
    res.send 200, { nodejs: true }

  # More general middleware
  app.use express.static(path.resolve __dirname, "../public")

  if SENTRY_DSN
    client = new raven.Client SENTRY_DSN, {
      stackFunction: Error.prepareStackTrace
    }
    app.use raven.middleware.express(client)
    client.patchGlobal ->
      console.log('Uncaught Exception. Process exited by raven.patchGlobal.')
      process.exit(1)
