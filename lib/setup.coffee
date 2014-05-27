#
# Sets up intial project settings, middleware, mounted apps, and
# global configuration such as overriding Backbone.sync and
# populating sharify data
#

{ API_URL, NODE_ENV, TAKOMAN_ID, TAKOMAN_SECRET, COOKIE_DOMAIN, SESSION_SECRET,
  SESSION_COOKIE_KEY, SESSION_COOKIE_MAX_AGE, FACEBOOK_ID, FACEBOOK_SECRET } = config = require "../config"
_               = require "underscore"
express         = require "express"
Backbone        = require "backbone"
sharify         = require "sharify"
path            = require "path"
bodyParser      = require 'body-parser'
cookieParser    = require 'cookie-parser'
session         = require 'cookie-session'
CurrentUser     = require '../models/current_user'
takomanPassport       = require "./middleware/takoman-passport"
takomanXappMiddlware  = require "./middleware/takoman-xapp-middleware"

# Inject some constant data into sharify
sharify.data =
  API_URL: API_URL
  ASSET_PATH: ASSET_PATH
  JS_EXT: (if "production" is NODE_ENV then ".min.js" else ".js")
  CSS_EXT: (if "production" is NODE_ENV then ".min.css" else ".css")

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

  # Mount apps
  app.use require "../apps/commits"
  app.use require "../apps/auth"

  # More general middleware
  app.use express.static(path.resolve __dirname, "../public")
