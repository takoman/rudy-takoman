_ = require 'underscore'
Backbone = require 'backbone'
{ API_URL } = require('sharify').data

module.exports = class Merchant extends Backbone.Model

  urlRoot: "#{sd.API_URL}/api/v1/merchants"
