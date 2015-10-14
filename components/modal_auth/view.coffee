_           = require 'underscore'
Backbone    = require 'backbone'
AuthView    = require "../../components/auth/client/index.coffee"
template    = -> require('./template.jade') arguments...

module.exports = class ModalAuthView extends Backbone.View
  defaults: ->
    hashTracking: false
    closeOnConfirm: true
    closeOnCancel: true
    closeOnEscape: true
    closeOnOutsideClick: false

  initialize: (options = {}) ->
    { @$trigger, @hashTracking, @closeOnConfirm, @closeOnCancel,
      @closeOnEscape, @closeOnOutsideClick } = _.defaults options, @defaults()

    @$el.html template()

    remodal = require '../../lib/vendor/remodal.js'
    modalId = "modal-auth-id-#{_.uniqueId()}"
    @$trigger.attr 'data-remodal-target', modalId
    @$('.modal').attr 'data-remodal-id', modalId

    @modal = @$('.modal').remodal
      hashTracking: @hashTracking
      closeOnConfirm: @closeOnConfirm
      closeOnCancel: @closeOnCancel
      closeOnEscape: @closeOnEscape
      closeOnOutsideClick: @closeOnOutsideClick

    new AuthView el: @modal.$modal

    # Events
    @modal.$modal.on 'confirmation', -> options.onConfirmation?()

    # Show the first tab according to the data-tab attribute of the $trigger.
    @$trigger.on 'click', (e) =>
      @modal.$modal.find('[data-tab]').removeClass 'in active'
      @modal.$modal.find("[data-tab='#{$(e.target).data('active-tab')}']").addClass 'in active'
