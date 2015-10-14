#
# Routes file that exports route handlers for ease of testing.
#

@index = (req, res, next) ->
  res.render 'index'
