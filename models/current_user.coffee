_         = require 'underscore'
Backbone  = require 'backbone'
sd        = require('sharify').data

module.exports = class CurrentUser extends Backbone.Model

  url: -> "#{sd.API_URL}/api/v1/me"

  # Add the access token to fetches and saves
  sync: (method, model, options={}) ->
    if method in ['create', 'update', 'patch']
      # If persisting to the server overwrite attrs
      options.attrs = _.omit(@toJSON(), 'accessToken')
    else
      # Otherwise overwrite data
      _.defaults(options, { data: { access_token: @get('accessToken') } })
    Backbone.Model::sync.call this, arguments...
