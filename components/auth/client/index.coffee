_ = require 'underscore'
Q = require 'q'
Backbone = require 'backbone'

module.exports = class AuthView extends Backbone.View
  events:
    "submit #form-signup": "signup"
    "submit #form-login": "login"

  initialize: (options) -> undefined

  login: (e) ->
    e.preventDefault()

    model = new Backbone.Model
      email: $('#form-login input[name="email"]').val()
      password: $('#form-login input[name="password"]').val()
    model.url = -> "/users/login"

    Q(model.save())
      .then (result) =>
        @$('.alert').html(result.message)
          .removeClass().addClass 'alert alert-success'
      .catch (error) =>
        error_dict = $.parseJSON(error.responseText)
        @$('.alert').html(error_dict.message)
          .removeClass().addClass 'alert alert-danger'
      .done()

  signup: (e) ->
    e.preventDefault()

    model = new Backbone.Model
      name: $('#form-signup input[name="email"]').val()
      email: $('#form-signup input[name="email"]').val()
      password: $('#form-signup input[name="password"]').val()
    model.url = -> "/users/signup"

    Q(model.save())
      .then (result) =>
        @$('.alert').html(result.message)
          .removeClass().addClass 'alert alert-success'
      .catch (error) =>
        error_dict = $.parseJSON(error.responseText)
        @$('.alert').html(error_dict.message)
          .removeClass().addClass 'alert alert-danger'
      .done()
