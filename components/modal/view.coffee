_           = require 'underscore'
Backbone    = require 'backbone'
mediator    = require '../../lib/mediator.coffee'

modalTemplate = -> require('./modal.jade') arguments...

module.exports = class ModalView extends Backbone.View
  id: 'modal'

  container: '#modal-container'

  template: -> 'Requires a template'

  templateData: {}

  events: ->
    'click.handler .modal-backdrop' : 'close'
    'click.handler .modal-close'    : 'close'

    'click.internal .modal-dialog'   : '__intercept__'

  initialize: (options = {}) ->
    { @width, @transition, @backdrop } = _.defaults options, width: '400px', transition: 'fade', backdrop: true

    _.extend @templateData, autofocus: @autofocus()

    @resize = _.debounce @updatePosition, 100

    @$window = $(window)
    @$window.on 'keyup', @escape
    @$window.on 'resize', @resize

    mediator.on 'modal:close', @close, this
    mediator.on 'modal:opened', @updatePosition, this

    @open()

  __intercept__: (e) ->
    e.stopPropagation()

  escape: (e) ->
    return unless e.which is 27

    mediator.trigger 'modal:close'

  updatePosition: =>
    @$dialog.css
      top:  ((@$el.height() - @$dialog.height()) / 2) + 'px'
      left: ((@$el.width() - @$dialog.width()) / 2) + 'px'

  # TODO if isTouchDevice, return undefined
  autofocus: -> true

  setWidth: (width) ->
    @$dialog.css { width: width or @width }

  setup: ->
    backdropClass = if @backdrop then 'has-backdrop' else 'has-nobackdrop'

    @$el.
      addClass("is-#{@transition}-in #{backdropClass}").
      # Render outer
      html modalTemplate()

    @renderInner()

    # Display
    $(@container).html @$el

    @postRender()

    # Disable scroll on body
    $('body').addClass 'is-modal'

    # Fade in
    _.defer => @$el.attr 'data-state', 'open'

  renderInner: =>
    @$body = @$('.modal-body')
    @$body.html @template(@templateData)
    @$dialog = @$('.modal-dialog')
    @setWidth()

  postRender: -> undefined

  open: ->
    @setup()

    mediator.trigger 'modal:opened'

    this

  close: ->
    @$window.off 'keyup', @escape
    @$window.off 'resize', @resize

    mediator.off null, null, this

    @$el
      .attr('data-state', 'closed')
      .one($.support.transition.end, =>
        # Re-enable scrolling
        $('body').removeClass 'is-modal'

        mediator.trigger 'modal:closed'

        @remove()
      ).emulateTransitionEnd 250
