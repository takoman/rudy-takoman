# 	
# Routes file that exports route handlers for ease of testing.
#

@index = (req, res, next) ->
  res.render "index"
@log_in_check = (req, res, next ) ->
  res.end "Welcome to the sign in check page!"