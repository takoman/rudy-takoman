_ = require 'underscore'
Backbone = require 'backbone'

module.exports = class AllPayModal extends Backbone.View
  # We can also use simple _.template templating language
  # http://underscorejs.org/#template
  template: ->
    '<div class="allpay-form-placeholder"></div>' +
    '<div class="allpay-window-overlay"></div>' +
    '<iframe class="allpay-window" name="allpay-window" width="1000px" height="800px"></iframe>'

  initialize: (options) ->
    { @data } = options
    @model = new Backbone.Model()
    @model.url = '/allpay-payment-form-html'

    @listenTo @model, 'sync', @postToIframe
    @listenTo @model, 'error', @showErrors

    @render()

  render: ->
    @$el.html @template()

  startPayment: ->
    # Backbone by default expects the response to be JSON, so we have to
    # provide the expected res data type to be "text" or "html". Otherwise,
    # it will always trigger the error event.
    # http://stackoverflow.com/questions/29292113/backbone-save-respond-with-success
    # http://api.jquery.com/jquery.ajax/
    @model.fetch data: @data, dataType: "html"

  postToIframe: (model, res, options) ->
    $('body').addClass 'no-scroll'
    @$('.allpay-form-placeholder').html(res)
      .find('form').attr('target', 'allpay-window')
      .submit()

  showErrors: (model, res, options) ->
    console.log 'failed to generate AllPay form'
