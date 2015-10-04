_ = require 'underscore'
Backbone = require 'backbone'
itemTemplate = -> require("./template.jade") arguments...

module.exports = class ProfileCoverModal extends Backbone.View
  template: -> itemTemplate()

  events:
    'click .thumbnail': 'thumbnailPreview'

  initialize: (options) ->
    @render()

  render: ->
    remodal = require '../../lib/vendor/remodal.js'
    @setElement $(@template())
    @modal = @$el.remodal
      hashTracking: false

  open: ->
    @modal.open()

  thumbnailPreview: (e) ->
    src = $(e.currentTarget).find('img').attr('src');
    @$('.cover-modal-preview-img img').attr('src', src)
