{ API_URL, APP_URL } = require('sharify').data

module.exports =
  related: ->
    return @__related__ if @__related__?

    Merchant = require '../../../models/merchant.coffee'

    merchant = new Merchant()

    @__related__ =
      merchant: merchant
