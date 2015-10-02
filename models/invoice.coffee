_ = require 'underscore'
Backbone = require 'backbone'
SantaModel = require './mixins/santa_model.coffee'
{ API_URL, APP_URL } = require('sharify').data

module.exports = class Invoice extends Backbone.Model

  _.extend @prototype, SantaModel

  urlRoot: -> "#{API_URL}/api/v1/invoices"

  url: ->
    return @urlRoot() if @isNew()
    url = "#{@urlRoot()}/#{@id}"
    url = "#{url}?access_key=#{accessKey}" if (accessKey = @get('access_key'))?
    url

  href: -> "#{APP_URL}/invoices/#{@get('_id')}"

  isUnpaid: -> @get('status') is 'unpaid'
  isPaid: -> @get('status') is 'paid'
  isOrverdue: -> @get('status') is 'overdue'
