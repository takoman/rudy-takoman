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
sd = require("sharify").data
CurrentUser = require "../../models/current_user.coffee"
AuthView = require "../../components/auth/client/index.coffee"

module.exports.LoginView = class LoginView extends Backbone.View

  initialize: ->
    @user = CurrentUser.orNull()
    new AuthView el: @$('.auth')

module.exports.init = ->
  new LoginView el: $ "body"
