# 	
# Routes file that exports route handlers for ease of testing.
#

{ parse } = require "url"

@index = (req, res, next) ->
  res.render "index"

@redirectBack = (req, res, next ) ->
  url = req.body["redirect-to"]   or
        req.query["redirect-to"]  or
        req.param("redirect_uri") or
        parse(req.get("Referrer") or "").path or
        "/"
  res.redirect url

@logout = (req, res, next) ->
  req.logout()
  next()
