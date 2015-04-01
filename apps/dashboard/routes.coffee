#
# Routes file that exports route handlers for ease of testing.
#

@orderCreation = (req, res, next) ->
  # TODO In addition, we have to check if the user is a merchant.
  # If he/she is a regular user, 404.
  return res.redirect '/login' unless req.user
  res.render 'order_creation'
