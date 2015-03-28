#
# Routes file that exports route handlers for ease of testing.
#

{ parse } = require "url"

@orderCreation = (req, res, next) ->
  res.render "order_creation"
