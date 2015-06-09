#
# Using ["The Twelve-Factor App"](http://12factor.net/) as a reference all
# environment configuration will live in environment variables. This file
# simply lays out all of those environment variables with sensible defaults
# for development.
#

module.exports =
  API_URL                     : 'http://localhost:5000'
  APP_NAME                    : 'Rudy'
  APP_URL                     : 'http://localhost:4000'
  ALLPAY_PLATFORM_ID          : 'replace-me'
  ALLPAY_AIO_HASH_KEY         : 'replace-me'
  ALLPAY_AIO_HASH_IV          : 'replace-me'
  ALLPAY_AIO_CHECKOUT_URL     : 'http://payment-stage.allpay.com.tw/Cashier/AioCheckOut'
  ALLPAY_AIO_ORDER_QUERY_URL  : 'http://payment-stage.allpay.com.tw/Cashier/QueryTradeInfo'
  CDN_URL                     : 'replace-me'
  COOKIE_DOMAIN               : null
  FACEBOOK_ID                 : 'replace-me'
  FACEBOOK_SECRET             : 'replace-me'
  GOOGLE_ANALYTICS_ID         : null
  NEW_RELIC_LICENSE_KEY       : null
  NODE_ENV                    : 'development'
  PORT                        : 4000
  S3_KEY                      : 'replace-me'
  S3_SECRET                   : 'replace-me'
  S3_BUCKET                   : 'replace-me'
  S3_UPLOAD_DIR               : 'uploads'
  SENTRY_DSN                  : null
  SENTRY_PUBLIC_DSN           : null
  SESSION_SECRET              : 'F0rc3'
  SESSION_COOKIE_MAX_AGE      : 31536000000
  SESSION_COOKIE_KEY          : 'rudy.sess'
  TAKOMAN_ID                  : 'replace-me'
  TAKOMAN_SECRET              : 'replace-me'

# Override any values with env variables if they exist.
# You can set JSON-y values for env variables as well such as "true" or
# "['foo']" and config will attempt to JSON.parse them into non-string types.
for key, val of module.exports
  val = (process.env[key] or val)
  module.exports[key] = try JSON.parse(val) catch then val

# Warn if this file is included client-side.
alert("WARNING: Do not require config.coffee, please require('sharify').data instead.") if window?
