_ = require 'underscore'
Q = require 'q'
Backbone = require "backbone"
Merchant = require '../../../models/merchant.coffee'
ProfileCoverModalView = require '../../../components/profile_cover_modal/view.coffee'
{ API_URL, MERCHANT } = require('sharify').data

module.exports.ProfileEditingView = class ProfileEditingView extends Backbone.View

  initialize: (options) ->
    { @merchant } = options
    @coverModal = new ProfileCoverModalView

  events:
    'click .save-profile': 'saveProfile',
    'click .cover-choose': 'chooseCover',
    'keyup .form-profile [name="merchant_name"]': 'updateMerchantName'
    'keyup .form-profile [name="merchant_desc"]': 'updateMerchantDesc'
    'click .save-profile': 'saveProfile'

  chooseCover: ->
    @coverModal.open()

  updateMerchantName: ->
    @$('.profile-info-h1').text(@$('.form-profile [name="merchant_name"]').val())

  updateMerchantDesc: ->
    desc = @$('.form-profile [name="merchant_desc"]').val()
    desc = desc.replace new RegExp('\r?\n','g'), '<br>'
    @$('.profile-cover-desc').html(desc)

  saveProfile: (e) ->
    e.preventDefault()
    name = @$('.form-profile [name="merchant_name"]').val()
    desc = @$('.form-profile [name="merchant_desc"]').val()
    @merchant.set
      merchant_name: name
      merchant_desc: desc
    @merchant.save()

module.exports.init = ->
  new ProfileEditingView
    el: $ "body"
    merchant: new Merchant MERCHANT