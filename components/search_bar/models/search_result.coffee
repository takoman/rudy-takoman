_ = require 'underscore'
_s = require 'underscore.string'
Backbone = require 'backbone'

module.exports = class SearchResult extends Backbone.Model

  initialize: (options) ->
    @set
      display: @display()

    # Used by typeahead.js to set value of the input control after
    # a suggestion is selected.
    @value = @display()

  display: ->
    _s.trim @get('name')
