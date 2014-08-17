# 	
# Routes file that exports route handlers for ease of testing.
#

@index = (req, res, next) ->
  res.render "index"

@redirectBack = (req, res, next ) ->
  res.send status: "success", message: "You have successfully logged in!"
