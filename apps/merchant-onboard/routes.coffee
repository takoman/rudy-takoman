#
# Routes file that exports route handlers for ease of testing.
#

@new = (req, res, next) ->
  return res.redirect '/login' unless req.user
  res.render 'new'
