_           = require 'underscore'
Backbone    = require 'backbone'
remodal     = require '../../lib/vendor/remodal.js'
template    = -> require('./template.jade') arguments...

module.exports = class ModalDialogView extends Backbone.View
  defaults:
    hashTracking: false
    closeOnConfirm: true
    closeOnCancel: true
    closeOnEscape: true
    closeOnOutsideClick: true
    modalHeader: """
    """
    modalContent: """
    """
    cancelLabel: '取消'
    confirmLabel: '確定'

  initialize: (options = {}) ->
    { @$trigger, @hashTracking, @closeOnConfirm, @closeOnCancel, @closeOnEscape,
      @closeOnOutsideClick, @modalHeader, @modalContent, @cancelLabel,
      @confirmLabel } = _.defaults options, @defaults

    modalId = "modal-dialog-id-#{_.uniqueId()}"
    @$el.html template
      modalId: modalId
      modalHeader: @modalHeader
      modalContent: @modalContent
      cancelLabel: @cancelLabel
      confirmLabel: @confirmLabel

    @$trigger.attr 'data-remodal-target', modalId

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
