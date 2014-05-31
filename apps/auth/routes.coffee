# 	
# Routes file that exports route handlers for ease of testing.
#

@index = (req, res, next) ->
	res.render "index", msg: 'Please Sign In'
@log_in_check = (req, res, next ) ->
  #res.end "Welcome to the sign in check page!"
  #console.log req.body.email
  Account = req.body.user.account;
  res.render "index", msg: 'Welcome Back ' + Account