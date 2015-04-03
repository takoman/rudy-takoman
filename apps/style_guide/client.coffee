#
# The client-side code for the style_guide page.
#
# [Browserify](https://github.com/substack/node-browserify) lets us write this
# code as a common.js module, which means requiring dependecies instead of
# relying on globals. This module exports the Backbone view and an init
# function that gets used in /assets/commits.coffee. Doing this allows us to
# easily unit test these components, and makes the code more modular and
# composable in general.
#
_        = require 'underscore'
Backbone = require "backbone"
sd = require("sharify").data

module.exports.StyleGuideView = class StyleGuideView extends Backbone.View

  initialize: -> undefined

  events:
    'click .btn': 'buttonLoading'

  buttonLoading: (e) ->
    $btn = $(e.currentTarget)
    $btn.addClass 'is-loading'
    setTimeout (-> $btn.removeClass 'is-loading'), 1500

module.exports.init = ->
  new StyleGuideView
    el: $ "body"
