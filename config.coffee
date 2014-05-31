#
# Using ["The Twelve-Factor App"](http://12factor.net/) as a reference all 
# environment configuration will live in environment variables. This file 
# simply lays out all of those environment variables with sensible defaults 
# for development.
#

module.exports =
  
  API_URL                 : "http://localhost:5000"
  ASSET_PATH              : "/assets/"
  COOKIE_DOMAIN           : null
  FACEBOOK_ID             : '302772989887077'
  FACEBOOK_SECRET         : '02fcc1826933a1e39abce8e22edb8f3e'
  NODE_ENV                : 'development'
  SESSION_SECRET          : 'F0rc3'
  SESSION_COOKIE_MAX_AGE  : 31536000000
  SESSION_COOKIE_KEY      : 'rudy.sess'
  PORT                    : 4000
  TAKOMAN_ID              : '55050a745ff16a8114b8'
  TAKOMAN_SECRET          : '752dc05799b6fec555f5436a512fccdb'

# Override any values with env variables if they exist
module.exports[key] = (process.env[key] or val) for key, val of module.exports
