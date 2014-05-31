#
# The client-side code for the commits page.
#
# [Browserify](https://github.com/substack/node-browserify) lets us write this
# code as a common.js module, which means requiring dependecies instead of
# relying on globals. This module exports the Backbone view and an init
# function that gets used in /assets/commits.coffee. Doing this allows us to
# easily unit test these components, and makes the code more modular and
# composable in general.
#

Backbone = require "backbone"
Backbone.$ = $
sd = require("sharify").data
Commits = require "../../collections/commits.coffee"
listTemplate = -> require("./templates/list.jade") arguments...
#BorderedDropdown = require "../../components/bordered_dropdown/view.coffee"
ModalView = require "../../components/modal/view.coffee"

module.exports.CommitsView = class CommitsView extends Backbone.View

  initialize: ->
    @collection.on "sync", @render

  render: =>
    @$("#commits-list").html listTemplate(commits: @collection.models)
    #new BorderedDropdown el: $('.bordered-dropdown')

  events:
    "change .search-input": "changeRepo"
    "click .modal-button": "openModal"

  changeRepo: (e) ->
    @collection.repo = $(e.target).val()
    @collection.fetch()

  openModal: (e) ->
    new ModalView()

module.exports.init = ->
  new CommitsView
    el: $ "body"
    collection: new Commits sd.COMMITS, owner: "artsy", repo: "flux"
