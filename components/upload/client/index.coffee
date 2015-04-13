_ = require 'underscore'
# We "require" the blueimp-file-upload module, which uses the "required"
# jQuery module, instead of the global jQuery.
# https://github.com/blueimp/jQuery-File-Upload/blob/6c352d87b9e59af254884ed6bc61475779ec4e5e/js/jquery.fileupload.js#L26
# So we require jQuery first and make Backbone use that one.
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
    $form.fileupload
      url: "https://#{S3_BUCKET}.s3.amazonaws.com"
      type: 'POST'
      dataType: 'xml'
      autoUpload: true
      # Refer to all the callback options in the official doc.
      # https://github.com/blueimp/jQuery-File-Upload/wiki/Options#callback-options
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
        options.onSend?(e, data)
      progress: (e, data) ->
        # Callback for upload progress events.
        options.onProgress?(e, data)
      fail: (e, data) ->
        # Callback for failed (abort or error) upload requests. This callback
        # is the equivalent to the error callback provided by jQuery ajax()
        # and will not be called if the server returns a JSON response with
        # an error property, as this counts as successful request due to the
        # successful HTTP response.
        #   data.errorThrown
        #   data.textStatus
        #   data.jqXHR
        options.onFail?(e, data)
      done: (e, data) ->
        # Callback for successful upload requests. This callback is the
        # equivalent to the success callback provided by jQuery ajax() and
        # will also be called if the server returns a JSON response with
        # an error property.
        #   data.result
        #   data.textStatus;
        #   data.jqXHR;
        # URL of the file upload to S3 can be found via
        #   $(data.result).find('Location').text()
        options.onDone?(e, data)
