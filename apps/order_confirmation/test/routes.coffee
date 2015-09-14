_               = require 'underscore'
Q               = require 'q'
sinon           = require 'sinon'
Backbone        = require 'backbone'
routes          = require '../routes'
Order           = require '../../../models/order.coffee'
OrderLineItems  = require '../../../collections/order_line_items.coffee'

describe 'Order confirmation routes', ->
  beforeEach ->
    @res = { render: sinon.stub(), redirect: sinon.stub(), locals: { sd: {} } }

  describe '#index', ->
    describe 'without access key', ->
      beforeEach ->
        req = { query: {} }
        routes.index req, @res

      it 'redirects to the log in page', ->
        @res.redirect.args[0][0].should.equal '/login'

    describe 'with access key', ->
      beforeEach ->
        @sync = sinon.stub Backbone, 'sync'
        @orderDfd = Q.defer()
        @orderLineItemsDfd = Q.defer()
        @sync.withArgs('read', new Order()).returns @orderDfd.promise
        @sync.withArgs('read', new OrderLineItems()).returns @orderLineItemsDfd.promise
        @req = { params: { id: '1' }, query: { access_key: 'universal_key' } }
        @next = sinon.stub()
        routes.index @req, @res, @next

      afterEach ->
        Backbone.sync.restore()

      describe 'order and order line items fetched successfully', ->
        it 'renders the correct template', (done) ->
          @sync.args.length.should.equal 2
          @orderDfd.resolve()
          _.defer =>
            @orderLineItemsDfd.resolve()
            _.defer =>
              @res.render.args[0][0].should.equal "index"
              done()

        xit 'renders the template with correct data', (done) -> undefined

      describe 'failed to order and order line items', ->
        it 'calls the error handler with correct message', (done) ->
          @sync.args.length.should.equal 2
          @orderDfd.resolve()
          _.defer =>
            @orderLineItemsDfd.reject body: message: 'WHAAAAAT!'
            _.defer =>
              @next.calledWith('WHAAAAAT!').should.be.ok
              done()
