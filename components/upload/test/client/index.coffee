_           = require 'underscore'
sd          = require('sharify').data
benv        = require 'benv'
sinon       = require 'sinon'
rewire      = require 'rewire'
Backbone    = require 'backbone'
{ resolve } = require 'path'

describe 'UploadForm', ->
  beforeEach (done) ->
    benv.setup =>
      benv.expose $: benv.require 'jquery'
      sinon.stub Backbone, 'sync'

      # In the UploadForm view, we "require" the blueimp-file-upload module
      # which uses the "required" jQuery module, instead of the global jQuery.
      # https://github.com/blueimp/jQuery-File-Upload/blob/6c352d87b9e59af254884ed6bc61475779ec4e5e/js/jquery.fileupload.js#L26
      #
      # In order to stub the fileupload plugin attached to the required jQuery,
      # we can require jQuery first in the test (so later when the view
      # requires jQuery, it will use the cached one), and stub the plugin
      # before it actually gets used in the view.
      #
      # Note that since we have a global window object now, we can simply
      # require jQuery here.
      # https://github.com/jquery/jquery/blob/062b5267d0a3538f1f6dee3df16da536b73061ea/src/intro.js#L38
      _$ = require('jquery')
      sd.S3_BUCKET = 'my-s3-bucket'
      UploadForm = benv.requireWithJadeify resolve(
        __dirname, '../../client/index.coffee'
      ), ['template']
      @fileupload = sinon.stub _$.fn, 'fileupload'
      @view = new UploadForm
        el: $('body')
        onSend: (@onSend = sinon.stub())
        onProgress: (@onProgress = sinon.stub())
        onFail: (@onFail = sinon.stub())
        onDone: (@onDone = sinon.stub())
      done()

  afterEach ->
    Backbone.sync.restore()
    @fileupload.restore()
    benv.teardown()

  describe '#initialize', ->
    it 'initializes the jQuery File Upload widget with proper options', ->
      @fileupload.calledOnce.should.be.ok
      @fileupload.args[0][0].url.should.eql 'https://my-s3-bucket.s3.amazonaws.com'
      @fileupload.args[0][0].type.should.eql 'POST'
      @fileupload.args[0][0].dataType.should.eql 'xml'
      @fileupload.args[0][0].autoUpload.should.eql true

    describe 'on add', ->
      beforeEach ->
        _$ = require('jquery')
        @ajax = sinon.stub _$, 'ajax'
        e = $.Event 'click'
        data = { files: [{ name: '香奈兒包.jpg' }], submit: -> undefined }
        @fileupload.args[0][0].add(e, data)

      afterEach ->
        @ajax.restore()

      it 'fetches signed S3 form data via ajax', ->
        @ajax.calledOnce.should.be.ok
        @ajax.args[0][0].url.should.eql '/s3-signed'
        @ajax.args[0][0].type.should.eql 'GET'
        @ajax.args[0][0].dataType.should.eql 'json'
        @ajax.args[0][0].data.should.eql { filename: '香奈兒包.jpg' }

      it 'fills out the form with fetched form data', ->
        @ajax.args[0][0].success
          key: 'key_value'
          awsAccessKeyId: 'awsAccessKeyId_value'
          acl: 'acl_value'
          policy: 'policy_value'
          signature: 'signature_value'
          contentType: 'contentType_value'
        @view.$('input[name="key"]').val().should.eql 'key_value'
        @view.$('input[name="AWSAccessKeyId"]').val().should.eql 'awsAccessKeyId_value'
        @view.$('input[name="acl"]').val().should.eql 'acl_value'
        @view.$('input[name="policy"]').val().should.eql 'policy_value'
        @view.$('input[name="signature"]').val().should.eql 'signature_value'
        @view.$('input[name="Content-Type"]').val().should.eql 'contentType_value'

    describe 'custom callbacks', ->
      it 'calls custom callbacks passed in the options properly', ->
        e = $.Event 'click'
        data = { message: "I don't know how many of you have ever met Dijkstra, but you probably know that arrogance in computer science is measured in nano-Dijkstras." }
        @fileupload.args[0][0].send(e, data)
        @fileupload.args[0][0].progress(e, data)
        @fileupload.args[0][0].progress(e, data)
        @fileupload.args[0][0].fail(e, data)
        @fileupload.args[0][0].done(e, data)

        _.each [@onSend, @onFail, @onDone], (callback) ->
          callback.calledOnce.should.be.ok
          callback.args[0][0].should.equal e
          callback.args[0][1].should.equal data
        @onProgress.calledTwice.should.be.ok
        @onProgress.args[0][0].should.equal e
        @onProgress.args[0][1].should.equal data
        @onProgress.args[1][0].should.equal e
        @onProgress.args[1][1].should.equal data
