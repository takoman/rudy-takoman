_           = require 'underscore'
Backbone    = require 'backbone'
template    = -> require('./template.jade') arguments...

module.exports = class ModalDialogView extends Backbone.View
  defaults:
    hashTracking: false
    closeOnConfirm: true
    closeOnCancel: true
    closeOnEscape: true
    closeOnOutsideClick: true
    template: template()

  initialize: (options = {}) ->
    { @$trigger, @template, @hashTracking, @closeOnConfirm, @closeOnCancel,
      @closeOnEscape, @closeOnOutsideClick } = _.defaults options, @defaults

    @$el.html @template

    remodal = require '../../lib/vendor/remodal.js'
    modalId = "modal-dialog-id-#{_.uniqueId()}"
    @$trigger.attr 'data-remodal-target', modalId
    @$('.modal').attr 'data-remodal-id', modalId

    @modal = @$('.modal').remodal
      hashTracking: @hashTracking
      closeOnConfirm: @closeOnConfirm
      closeOnCancel: @closeOnCancel
      closeOnEscape: @closeOnEscape
      closeOnOutsideClick: @closeOnOutsideClick

    # Events
    @modal.$modal.on 'confirmation', -> options.onConfirmation?()

  remove: ->
    @modal.destroy()
    super()
