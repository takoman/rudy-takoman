Backbone = require 'backbone'
Backbone.$ = $
sd = require('sharify').data
SearchBarView = require '../../components/search_bar/view.coffee'

module.exports.ProfileView = class ProfileView extends Backbone.View

  initialize: ->
    @searchBarView = new SearchBarView
      el: @$('#main-layout-search-bar-container')
      $input: @$('#main-layout-search-bar-input')
      displayEmptyItem: true
      autoselect: true
      limit: 7

    @searchBarView.on 'search:entered', (term) -> window.location = "/search?q=#{term}"
    @searchBarView.on 'search:selected', @searchBarView.selectResult

module.exports.init = ->
  new ProfileView
    el: $ 'body'
