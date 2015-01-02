_ = require 'underscore'
_s = require 'underscore.string'
Backbone = require 'backbone'
sd = require('sharify').data
SearchResults = require './collections/search_results.coffee'
mediator = require '../../lib/mediator.coffee'
itemTemplate = -> require('./templates/item.jade') arguments...
emptyItemTemplate = -> require('./templates/empty-item.jade') arguments...

###

 When input on focus

 +========================+
 | |                      |  <- Input field
 +========================+
 | Search Takoman         |  <- Feedback
 +========================+

 When typing

 +========================+
 | bag                    |  <- Input field
 +========================+
 | Search for "bag"       |  <- Header
 +========================+
 | School bag             |
 +------------------------+
 | Backpack               |
 +------------------------+  <- Suggestions
 | Shoulder Crossbody Bag |
 +------------------------+
 | Messenger Bag          |
 +========================+

###

module.exports = class SearchBarView extends Backbone.View
  defaults:
    limit: 4
    autoselect: false
    displayKind: true
    displayEmptyItem: false

  initialize: (options) ->
    return unless @$el.length

    { @$input, @limit, @autoselect, @displayKind, @displayEmptyItem } =
      _.defaults options, @defaults

    @$input ?= @$('input')
    throw new Error('Requires an input field') unless @$input?

    @searchResults = new SearchResults()

    @on 'search:start', @indicateLoading
    @on 'search:complete', @concealLoading
    @on 'search:complete', @displayFeedback
    @on 'search:opened', @displaySuggestions
    @on 'search:closed', @hideSuggestions

    @setupTypeahead()

  events:
    'keyup input': 'checkSubmission'

  checkSubmission: (e) ->
    @hideSuggestions()
    return if !(e.which is 13) or @selected?
    @trigger 'search:entered', @$input.val()

  indicateLoading: -> @$el.addClass 'is-loading'

  concealLoading: -> @$el.removeClass 'is-loading'

  displayFeedback: ->
    @hideSuggestions() if @searchResults.length

  renderFeedback: (feedback) ->
    @$feedback ?= @$ '.autocomplete-feedback'
    @$feedback.text feedback or 'Search Takoman'

  displaySuggestions: ->
    @renderFeedback()
    @$el.addClass 'is-display-suggestions'

  hideSuggestions: -> @$el.removeClass 'is-display-suggestions'

  setupTypeahead: ->
    # Set up Typeahead custom events
    _.each ['opened', 'closed', 'selected', 'cursorchanged'], (action) =>
      @$input.on "typeahead:#{action}", (args...) =>
        @trigger "search:#{action}", args...

    @$input.typeahead { autoselect: @autoselect },
      template: 'custom'
      templates:
        suggestion: @suggestionTemplate
        empty: -> '' # Typeahead won't render the header for empty results unless 'empty' is defined
        header: @emptyItemTemplate
      displayKey: 'value'
      name: _.uniqueId 'search'
      source: @setupBloodHound().ttAdapter()

  setupBloodHound: ->
    engine = new Bloodhound
      limit: @limit
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace 'value'
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: @searchResults.url()
        filter: (results) =>
          @searchResults.reset results
        ajax:
          beforeSend: (xhr) =>
            xhr.setRequestHeader 'X-XAPP-TOKEN', sd.TAKOMAN_XAPP_TOKEN
            @trigger 'search:start', xhr
          complete: (xhr) =>
            @trigger 'search:complete', xhr
    engine.initialize()
    engine

  suggestionTemplate: (item) ->
    itemTemplate item: item, displayKind: @displayKind

  emptyItemTemplate: (options) =>
    emptyItemTemplate(query: options.query) if @displayEmptyItem

  clear: -> @set ''

  set: (value) ->
    @$input.typeahead 'val', value
