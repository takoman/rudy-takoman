#
# Routes file that exports route handlers for ease of testing.
#

Commits = require "../../collections/commits"
{ NODE_ENV } = require "../../config"

@index = (req, res, next) ->
  commits = new Commits null,
    owner: "artsy"
    repo: "flare"
  unless NODE_ENV == 'test'
    commits.url = -> "https://api.github.com/repos/artsy/flare/commits"
  commits.fetch
    success: ->
      res.locals.sd.COMMITS = commits.toJSON()
      res.render "index", commits: commits.models
    error: (m, err) -> next err.text
