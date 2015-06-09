{ API_URL, APP_URL } = require('sharify').data

module.exports =
  related: ->
    return @__related__ if @__related__?

    Product = require '../../../models/product.coffee'

    product = new Product()

    @__related__ =
      product: product
