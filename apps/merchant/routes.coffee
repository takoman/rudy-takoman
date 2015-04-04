#
# Routes file that exports route handlers for ease of testing.
#

{ parse } = require "url"

@show = (req, res, next) ->
  res.render 'show'

@new = (req, res, next) ->
  # TODO Redirect to /login if no current url or current user already is a merchant.
  res.render 'new'
