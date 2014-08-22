sd = require('sharify').data

# Initialize analytics
module.exports = (options) =>
  { @ga } = options

  if sd.GOOGLE_ANALYTICS_ID
    googleAnalyticsParams = cookieDomain: 'takoman.co'

    if sd.CURRENT_USER?.id
      googleAnalyticsParams.userId = sd.CURRENT_USER?.id

    @ga? 'create', sd.GOOGLE_ANALYTICS_ID, googleAnalyticsParams

module.exports.trackPageview = =>
  # Don't track admins
  return if sd.CURRENT_USER?.role and 'admin' in sd.CURRENT_USER?.role

  @ga? 'send', 'pageview'

module.exports.registerCurrentUser = =>
  # Don't track admins
  return if sd.CURRENT_USER?.role and 'admin' in sd.CURRENT_USER?.role

  userType = if sd.CURRENT_USER then "Logged In" else "Logged Out"

  @ga? 'set', 'dimension1', userType
