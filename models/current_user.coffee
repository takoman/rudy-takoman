_         = require 'underscore'
Backbone  = require 'backbone'
sd        = require('sharify').data
SantaModel = require './mixins/santa_model.coffee'

module.exports = class CurrentUser extends Backbone.Model

  _.extend @prototype, SantaModel

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

  # Convenience for getting the bootstrapped user or returning null.
  # This should only be used on the client.
  @orNull: ->
    if sd.CURRENT_USER then new @(sd.CURRENT_USER) else null
