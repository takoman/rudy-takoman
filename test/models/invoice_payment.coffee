InvoicePayment = require '../../models/invoice_payment'
InvoicePayments = require '../../collections/invoice_payments'

describe "InvoicePayment", ->

  beforeEach ->
    @invoicePayment = new InvoicePayment()

  describe "#setAllPayOfflinePaymentData", ->

    describe 'ATM payment type', ->
      it 'sets the attributes properly', ->
        undefined

    describe 'CVS payment type', ->
      it 'sets the attributes properly', ->
        undefined

    describe 'BARCODE payment type', ->
      it 'sets the attributes properly', ->
        undefined

  describe '#setAllPayPaymentData', ->
    it 'sets the attributes properly', ->
      undefined

  describe '#parseAllPayPaymentReturnCode', ->
    undefined

  describe '#parseAllPayOfflinePaymentReturnCode', ->
    undefined

  describe '#isOffline', ->
    undefined

  describe '#aopd', ->
    undefined

  describe '#paymentType', ->
    undefined

  describe '#paymentTypeLabel', ->
    undefined

