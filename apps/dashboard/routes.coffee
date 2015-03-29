#
# Routes file that exports route handlers for ease of testing.
#

@orderCreation = (req, res, next) ->
  # TODO In addition, we have to check if the user is a merchant.
  # If he/she is a regular user, 404.
  res.redirect '/login' unless res.user
  res.render 'order_creation'