Order = require '../../models/order'

describe 'Order', ->

  beforeEach ->
    @order = new Order()

  describe '#url', ->
    describe 'order is new', ->
      it 'returns the correct url', ->
        order = new Order()
        order.url().should.equal order.urlRoot()

    describe 'order has an access_key', ->
      it 'returns the correct url', ->
        order = new Order(_id: '1', access_key: '1235')
        order.url().should.equal "#{order.urlRoot()}/1?access_key=1235"

    describe 'order has no access_key', ->
      it 'returns the correct url', ->
        order = new Order(_id: '1')
        order.url().should.equal "#{order.urlRoot()}/1"
