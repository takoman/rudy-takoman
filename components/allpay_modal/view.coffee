_ = require 'underscore'
Backbone = require 'backbone'

module.exports = class AllPayModal extends Backbone.View
  # We can also use simple _.template templating language
  # http://underscorejs.org/#template
  template: ->
    '<div class="allpay-modal">' +
    '  <div class="allpay-form-placeholder"></div>' +
    '  <iframe class="allpay-window" name="allpay-window" width="1000px" height="800px"></iframe>' +
    '</div>'

  initialize: (options) ->
    { @data } = options
    @model = new Backbone.Model()
    @model.url = '/allpay/payment-form-html'

    @listenTo @model, 'sync', @postToIframe
    @listenTo @model, 'error', @showErrors

    @render()

  render: ->
    remodal = require '../../lib/vendor/remodal.js'
    @setElement $(@template())
    @modal = @$el.remodal
      hashTracking: false
      closeOnConfirm: false
      closeOnCancel: false
      closeOnEscape: false
      closeOnOutsideClick: false
    @modal.open()

  startPayment: ->
    # Backbone by default expects the response to be JSON, so we have to
    # provide the expected res data type to be "text" or "html". Otherwise,
    # it will always trigger the error event.
    # http://stackoverflow.com/questions/29292113/backbone-save-respond-with-success
    # http://api.jquery.com/jquery.ajax/
    @model.save @data, { dataType: "html" }

  postToIframe: (model, res, options) ->
    @$('.allpay-form-placeholder').html(res)
      .find('form').attr('target', 'allpay-window')
      .submit()

  showErrors: (model, res, options) ->
    console.log 'failed to generate AllPay form'
