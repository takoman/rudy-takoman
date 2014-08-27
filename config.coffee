#
# Using ["The Twelve-Factor App"](http://12factor.net/) as a reference all
# environment configuration will live in environment variables. This file
# simply lays out all of those environment variables with sensible defaults
# for development.
#

module.exports =
  
  API_URL                 : 'http://localhost:5000'
  APP_NAME                : 'Rudy'
  APP_URL                 : 'http://localhost:4000'
  ASSET_PATH              : '/assets/'
  COOKIE_DOMAIN           : null
  FACEBOOK_ID             : '302847289879647'
  FACEBOOK_SECRET         : '2fea10f1093a56b1999bcc14124f1b25'
  GOOGLE_ANALYTICS_ID     : null
  NEW_RELIC_LICENSE_KEY   : null
  NODE_ENV                : 'development'
  PORT                    : 4000
  SENTRY_DSN              : null
  SENTRY_PUBLIC_DSN       : null
  SESSION_SECRET          : 'F0rc3'
  SESSION_COOKIE_MAX_AGE  : 31536000000
  SESSION_COOKIE_KEY      : 'rudy.sess'
  TAKOMAN_ID              : '55050a745ff16a8114b8'
  TAKOMAN_SECRET          : '752dc05799b6fec555f5436a512fccdb'

# Override any values with the ones in config-[RUDY_ENV].coffee
if (env = process.env.RUDY_ENV)
  config = require "./config/config-#{env}"
  module.exports[key] = (config[key] or val) for key, val of module.exports

# Override any values with env variables if they exist
module.exports[key] = (process.env[key] or val) for key, val of module.exports
