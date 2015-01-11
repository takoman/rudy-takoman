_ = require 'underscore'
benv = require 'benv'
Backbone = require 'backbone'
sinon = require 'sinon'
{ resolve } = require 'path'
SearchResult = require '../models/search_result'
SearchBarView = require '../view'
Bloodhound = -> ttAdapter: sinon.stub(), initialize: sinon.stub()
Bloodhound.tokenizers = obj: whitespace: sinon.stub()

describe 'SearchBarView', ->
  beforeEach (done) ->
    benv.setup =>
      benv.expose
        $: benv.require 'jquery'
        Bloodhound: Bloodhound
      Backbone.$ = $
      benv.render resolve(__dirname, '../template.jade'), {}, =>
        @$input = $('#main-layout-search-bar-input')
        @$input.typeahead = sinon.stub()
        @view = new SearchBarView el: $('#main-layout-search-bar-container'), $input: @$input
        done()

  afterEach ->
    benv.teardown()

  describe '#initialize', ->
    # NOTE: This will hang for some reason.
    xit 'listens to the relevant events', ->
      @view._events.should.have.keys 'search:start', 'search:complete', 'search:opened', 'search:closed', 'search:cursorchanged'

    describe '#setupTypeahead', ->
      it 'triggers events that happen on the input on the view', (done) ->
        finish = _.after 4, (-> done())
        @view.once 'search:opened', finish
        @view.once 'search:closed', finish
        @view.once 'search:selected', finish
        @view.once 'search:cursorchanged', finish
        @$input.trigger 'typeahead:opened'
        @$input.trigger 'typeahead:closed'
        @$input.trigger 'typeahead:selected'
        @$input.trigger 'typeahead:cursorchanged'

      it 'sets up typeahead', ->
        @$input.typeahead.args[0][1].name.should.be.an.instanceOf String
        @$input.typeahead.args[0][1].templates.suggestion.should.be.an.instanceOf Function
        @$input.typeahead.args[0][1].template.should.equal 'custom'
        @$input.typeahead.args[0][1].displayKey.should.equal 'value'

  describe '#indicateLoading', ->
    beforeEach ->
      @view.trigger 'search:start'

    it 'triggers the loading state of the component', ->
      @view.$el.attr('class').should.containEql 'is-loading'

    xit 'restores the feedback to the original state', ->
      @view.$el.html().should.containEql 'Search Takoman'

  describe '#concealLoading', ->
    it 'removes the loading state', ->
      @view.trigger 'search:start'
      @view.$el.attr('class').should.containEql 'is-loading'
      @view.trigger 'search:complete'
      _.isUndefined(@view.$el.attr('class')).should.be.ok

  describe '#displaySuggestions', ->
    it 'displays the feedback when the input is empty', ->
      @view.$('.autocomplete-feedback').text ''
      _.isEmpty(@view.$('input').text()).should.be.true
      @view.trigger 'search:opened'
      @view.$el.html().should.containEql 'Search Takoman'
      @view.$el.attr('class').should.containEql 'is-display-suggestions'

    xit 'does not display the feedback when the input has text', ->
      @view.$('input').val 'Foo Bar'
      @view.trigger 'search:opened'
      _.isEmpty(@view.$el.attr('class')).should.be.true

  describe '#hideSuggestions', ->
    it 'removes the open state', ->
      @view.trigger 'search:opened'
      @view.$el.attr('class').should.containEql 'is-display-suggestions'
      @view.trigger 'search:closed'
      _.isEmpty(@view.$el.attr('class')).should.be.true

  describe '#displayFeedback', ->
    it 'does not render a message when there are results', ->
      @view.searchResults.add name: 'takoman', value: 'Takoman'
      @view.searchResults.length.should.equal 1
      @view.trigger 'search:complete'
      @view.$el.html().should.not.containEql 'No results found'
      _.isEmpty(@view.$el.attr 'class').should.be.true
