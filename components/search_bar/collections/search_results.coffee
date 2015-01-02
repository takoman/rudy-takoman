_ = require 'underscore'
qs = require 'querystring'
sd = require('sharify').data
Backbone = require 'backbone'
SearchResult = require '../models/search_result.coffee'

module.exports = class SearchResults extends Backbone.Collection
  model: SearchResult

  url: -> "#{sd.API_URL}/api/v1/match?term=%QUERY" # %QUERY will be replaced by Bloodhound.
