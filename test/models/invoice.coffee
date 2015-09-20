Invoice = require '../../models/invoice'

describe 'Invoice', ->

  beforeEach ->
    @invoice = new Invoice()

  describe '#url', ->
    describe 'invoice is new', ->
      it 'returns the correct url', ->
        invoice = new Invoice()
        invoice.url().should.equal invoice.urlRoot()

    describe 'invoice has an access_key', ->
      it 'returns the correct url', ->
        invoice = new Invoice(_id: '1', access_key: '1235')
        invoice.url().should.equal "#{invoice.urlRoot()}/1?access_key=1235"

    describe 'invoice has no access_key', ->
      it 'returns the correct url', ->
        invoice = new Invoice(_id: '1')
        invoice.url().should.equal "#{invoice.urlRoot()}/1"
