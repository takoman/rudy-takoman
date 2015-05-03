_ = require 'underscore'
fs = require 'fs'
jade = require 'jade'
path = require 'path'
sinon = require 'sinon'
cheerio = require 'cheerio'
moment = require 'moment'
Backbone = require 'backbone'
Invoice = require '../../../models/invoice.coffee'
InvoiceLineItem = require '../../../models/invoice_line_item.coffee'
InvoiceLineItems = require '../../../collections/invoice_line_items.coffee'
fabricate = require '../../../test/helpers/fabricator.coffee'

render = (templateName) ->
  filename = path.resolve __dirname, "../templates/#{templateName}.jade"
  jade.compile(fs.readFileSync(filename), filename: filename)

describe 'Invoice', ->
  _.each ['draft', 'paid', 'overdue', 'void'], (s) ->
    describe "with status \"#{s}\"", ->
      beforeEach ->
        @invoice = new Invoice fabricate('invoice', status: s)
        @$ = cheerio.load render('index')
          moment: sinon.stub()
          sd: {}
          asset: (-> undefined)
          invoice: @invoice
          invoiceLineItems: new Backbone.Collection

      it 'renders the invalid invoice notice', ->
        @$('.notice').text().should.containEql '這份訂單已經失效'

      it 'does not render the invoice information', ->
        @$('.invoice-summary-panel').should.have.lengthOf 0
        @$('.invoice-line-items-table').should.have.lengthOf 0

  describe 'past due', ->
    beforeEach ->
      @invoice = new Invoice fabricate('invoice', due_at: '1999-12-31T00:00:00+00:00')
      @$ = cheerio.load render('index')
        moment: moment
        sd: {}
        asset: (-> undefined)
        invoice: @invoice
        invoiceLineItems: new Backbone.Collection

    it 'renders the invalid invoice notice', ->
      @$('.notice').text().should.containEql '這份訂單已經超過繳費期限'

    it 'does not render the invoice information', ->
      @$('.invoice-summary-panel').should.have.lengthOf 0
      @$('.invoice-line-items-table').should.have.lengthOf 0

  describe 'payable', ->
    beforeEach ->
      now = '2015-12-24T00:00:00+00:00'
      due = '2015-12-31T00:00:00+00:00'
      # Travel and freeze the time
      @clock = sinon.useFakeTimers(moment(now).unix() * 1000)
      @invoice = new Invoice fabricate('invoice', due_at: due)
      @invoiceLineItems = new InvoiceLineItems [fabricate('invoice_line_item')]
      @$ = cheerio.load render('index')
        _: _
        moment: moment
        sd: { INVOICE: @invoice.toJSON() }
        asset: (-> undefined)
        invoice: @invoice
        invoiceLineItems: @invoiceLineItems

    afterEach ->
      @clock.restore()

    it 'does not render notices', ->
      @$('.notice').should.have.lengthOf 0

    it 'renders the invoice information', ->
      due = moment(@invoice.get('due_at'))
      @$('.invoice-summary-panel').should.have.lengthOf 1
      @$('.invoice-summary-panel .invoice-due-at').text().should.containEql "#{due.year()} 年 #{due.month() + 1} 月 #{due.date()} 日"

    it 'renders the invoice line items information', ->
      @$('.invoice-line-items-table').should.have.lengthOf 1
      @$('.invoice-line-items-table tbody tr').should.have.lengthOf 1
      @$('.invoice-line-items-table .invoice-line-item-price').text().should.containEql @invoiceLineItems.at(0).get('price')
      @$('.invoice-line-items-table .invoice-line-item-quantity').text().should.eql @invoiceLineItems.at(0).get('quantity')
