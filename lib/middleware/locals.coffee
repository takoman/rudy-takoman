#
# Inject common project-wide [view locals](http://expressjs.com/api.html#app.locals).
#

_       = require 'underscore'
uuid    = require 'node-uuid'
moment  = require 'moment'
acct    = require 'accounting'
{ parse, format } = require 'url'

_.mixin require 'underscore.string'

acct.settings.currency = _.defaults
  precision: 0
  symbol: 'NT'
  format: '%s %v'
, acct.settings.currency

module.exports = (req, res, next) ->

  # Attach libraries to locals
  res.locals._ = _
  res.locals.moment = moment
  res.locals.acct = acct

  # Pass the user agent into locals for data-useragent device detection
  res.locals.userAgent = req.get('user-agent')

  # Inject some project-wide sharify data such as the session id, the current path
  # and the xapp token.
  res.locals.sd.SESSION_ID = req.session?.id ?= uuid.v1()
  res.locals.sd.CURRENT_PATH = parse(req.url).pathname
  res.locals.sd.TAKOMAN_XAPP_TOKEN = res.locals.takomanXappToken

  next()
