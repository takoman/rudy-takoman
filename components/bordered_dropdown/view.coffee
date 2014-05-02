_ = require 'underscore'
Backbone = require 'backbone'

module.exports = class BorderedDropdown extends Backbone.View

  events:
    'click .bordered-dropdown-options a': 'select'

  select: (e) ->
    $a = $(e.currentTarget)
    $a.addClass('bordered-dropdown-active')
    @$('.bordered-dropdown-options').css
      'margin-top': -@$('.bordered-dropdown-toggle').outerHeight() * $a.index()
    @$('.bordered-dropdown-text').text $a.text()
    @$('.bordered-dropdown-options').hidehover()
