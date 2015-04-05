#
# The client-side code for the merchant page.
#
# [Browserify](https://github.com/substack/node-browserify) lets us write this
# code as a common.js module, which means requiring dependecies instead of
# relying on globals. This module exports the Backbone view and an init
# function that gets used in /assets/commits.coffee. Doing this allows us to
# easily unit test these components, and makes the code more modular and
# composable in general.
#

_ = require "underscore"
Backbone = require "backbone"
Backbone.$ = $
sd = require("sharify").data
CurrentUser = require "../../../models/current_user.coffee"
Merchant = require "../../../models/merchant.coffee"

module.exports.MerchantView = class MerchantView extends Backbone.View

  initialize: ->
    @user = CurrentUser.orNull()

  events:
    'submit form#merchant-sign-up': 'createMerchant'

  createMerchant: (e) ->
    $form = $ e.currentTarget
    new Merchant(
      user: @user.get('_id')
      merchant_name: $form.find('input[name="merchant-name"]').val()
      source_countries: _.reduce($form.find('[name="source-countries"]:checked'),
        ((m, c) -> m.push($(c).val()); m), [])
    ).save(null,
      success: (model, response, options) ->
        $('#results').html JSON.stringify(model.attributes)
      error: (model, response, options) ->
        $('#results').html response
    )
    false

module.exports.init = ->
  new MerchantView el: $ "body"
