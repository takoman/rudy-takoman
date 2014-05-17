# 	
# Routes file that exports route handlers for ease of testing.
#

#Commits = require "../../collections/commits"

@index = (req, res, next) ->
  res.render "index"
  ###commits = new Commits null,
    owner: "artsy"
    repo: "flare"
  commits.fetch
    success: ->
      res.locals.sd.COMMITS = commits.toJSON()
      res.render "index", commits: commits.models
    error: (m, err) -> next err.text
  ###
@log_in_check = (req, res, next ) ->
  res.end "Welcome to the sign in check page!"