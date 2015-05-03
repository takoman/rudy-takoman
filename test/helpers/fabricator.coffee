#
# A function that helps create fixture data modeled after the Santa API.
# Pass in the name of the model and any extending data and it'll return
# a vanilla javascript object populated with fixture json data.
#
# e.g. `fabricate('product', { title: 'Three Wolf Moon' })`
#

_ = require 'underscore'

module.exports = fabricate = (type, extObj = {}) ->
  _.extend switch type

    when 'invoice'
      _id: _.uniqueId()
      invoice_no: _.uniqueId()
      order: fabricate 'order', customer: _.uniqueId(), merchant: _.uniqueId(), order_line_items: [_.uniqueId()]
      # TODO: figure out a way to fabricate bi-directional references
      # without infinite loop; leave it empty for now.
      invoice_line_items: []
      total: 150
      status: 'unpaid'
      due_at: '2099-01-01T00:00:00+00:00'
      created_at: '2000-01-01T00:00:00+00:00'
      updated_at: '2000-01-01T00:00:00+00:00'

    when 'invoice_line_item'
      _id: _.uniqueId()
      invoice: fabricate 'invoice', order: _.uniqueId(), invoice_line_items: [_.uniqueId()]
      order_line_item: fabricate 'order_line_item', order: _.uniqueId(), product: _.uniqueId()
      price: 150
      quantity: 1
      updated_at: "2015-04-26T00:35:27+00:00"
      created_at: "2015-04-26T00:35:27+00:00"

    when 'merchant'
      _id: _.uniqueId()
      user: fabricate 'user'
      merchant_name: '大潤發'
      source_countries: ['US', 'JP']
      updated_at: '2015-05-01T20:25:26+00:00'
      created_at: '2015-05-01T20:25:22+00:00'

    when 'order'
      _id: _.uniqueId()
      customer: fabricate 'user'
      merchant: fabricate 'merchant', user: _.uniqueId()
      status: 'new'
      # TODO: figure out a way to fabricate bi-directional references
      # without infinite loop; leave it empty for now.
      order_line_items: []
      total: 150
      currency_source: 'USD'
      currency_target: 'TWD'
      exchange_rate: 30
      updated_at: '2015-04-26T00:34:34+00:00'
      created_at: '2015-04-26T00:32:28+00:00'

    when 'order_line_item'
      _id: _.uniqueId()
      type: 'product'
      price: 150
      quantity: 1
      order: fabricate 'order', customer: _.uniqueId(), merchant: _.uniqueId(), order_line_items: [_.uniqueId()]
      product: fabricate 'product'
      updated_at: '2015-04-26T00:33:47+00:00'
      created_at: '2015-04-26T00:33:47+00:00'

    when 'product'
      _id: _.uniqueId()
      title: 'A&F 超帥氣夾克'
      brand: 'A&F'
      images: [{
        original: 'https://rudy-staging.s3.amazonaws.com/uploads%2Fde8205d5-49e7-47b4-90c8-0a8ecd997504.jpeg'
      }]
      urls: ['http://www.abercrombie.com/shop/us/mens-full-zip-hoodies-and-sweatshirts/henderson-lake-hooded-jacket-4198574_01?ofp=true']
      description: 'A&F 超帥氣夾克'
      updated_at: '2015-04-26T00:32:43+00:00'
      created_at: '2015-04-26T00:32:43+00:00'

    when 'user'
      _id: _.uniqueId()
      name: '周潤發'
      email: 'fager@gmail.com'
      role: ['user']
      updated_at: '2015-05-01T20:25:26+00:00'
      created_at: '2015-05-01T20:25:22+00:00'

  , extObj
