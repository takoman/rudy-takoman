#
# Routes file that exports route handlers for ease of testing.
#

#Commits = require "../../collections/commits"

@index = (req, res, next) ->
  res.render "index"
