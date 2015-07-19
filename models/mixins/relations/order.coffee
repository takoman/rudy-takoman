_ = require 'underscore'
{ API_URL, APP_URL } = require('sharify').data

module.exports =
  related: ->
    return @__related__ if @__related__?

    Customer = require '../../../models/user.coffee'
    Merchant = require '../../../models/merchant.coffee'

    merchant = new Merchant(if _.isString(@get('merchant')) then {_id: @get('merchant')} else @get('merchant'))
    customer = new Customer(if _.isString(@get('customer')) then {_id: @get('customer')} else @get('customer'))

    @__related__ =
      merchant: merchant
      customer: customer
