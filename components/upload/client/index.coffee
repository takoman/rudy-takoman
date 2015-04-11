_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$ = $
require 'blueimp-file-upload'
template = -> require('../templates/form.jade') arguments...
{ S3_BUCKET } = require('sharify').data

module.exports = class UploadForm extends Backbone.View

  initialize: (options) ->
    @$el.html template()
    $form = @$('form.s3-upload-form')
    $progressBar = @$('.progress-bar')
    $uploadResults = @$('.upload-results')
    $form.fileupload
      url: "https://#{S3_BUCKET}.s3.amazonaws.com"
      type: 'POST'
      dataType: 'xml'
      autoUpload: true
      add: (e, data) ->
        $.ajax
          url: '/s3-signed'
          type: 'GET'
          dataType: 'json'
          data: { filename: data.files[0].name }
          success: (formData) ->
            $form.find('input[name="key"]').val formData.key
            $form.find('input[name="AWSAccessKeyId"]').val formData.awsAccessKeyId
            $form.find('input[name="acl"]').val formData.acl
            $form.find('input[name="policy"]').val formData.policy
            $form.find('input[name="signature"]').val formData.signature
            $form.find('input[name="Content-Type"]').val formData.contentType
            data.submit()
      send: (e, data) ->
        # Callback for the start of each file upload request.
        # If this callback returns false, the file upload request is aborted.
        undefined
      progress: (e, data) ->
        # Callback for upload progress events.
        progress = parseInt(data.loaded / data.total * 100, 10)
        $progressBar.css 'width', progress + '%'
      fail: (e, data) ->
        # Callback for failed (abort or error) upload requests. This callback
        # is the equivalent to the error callback provided by jQuery ajax()
        # and will not be called if the server returns a JSON response with
        # an error property, as this counts as successful request due to the
        # successful HTTP response.
        #   data.errorThrown
        #   data.textStatus
        #   data.jqXHR
        undefined
      success: (data) ->
        url = $(data).find('Location').text()
        $uploadResults.html "<img src='#{url}'>"
      done: (e, data) ->
        # Callback for successful upload requests. This callback is the
        # equivalent to the success callback provided by jQuery ajax() and
        # will also be called if the server returns a JSON response with
        # an error property.
        #   data.result
        #   data.textStatus;
        #   data.jqXHR;
        undefined
