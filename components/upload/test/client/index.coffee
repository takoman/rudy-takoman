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
      Backbone.$ = $
      sinon.stub Backbone, 'sync'
      sd.S3_BUCKET = 'my-s3-bucket'
      @UploadForm = benv.requireWithJadeify resolve(
        __dirname, '../../client/index.coffee'
      ), ['template']
      @fileupload = $.fn.fileupload = sinon.stub()
      @view = new @UploadForm
        el: $('body')
        onSend: (@onSend = sinon.stub())
        onProgress: (@onProgress = sinon.stub())
        onFail: (@onFail = sinon.stub())
        onDone: (@onDone = sinon.stub())
      done()

  afterEach ->
    Backbone.sync.restore()
    benv.teardown()

  describe '#initialize', ->
    it 'initializes the jQuery File Upload widget with proper options', ->
      @fileupload.calledOnce.should.be.ok
      @fileupload.args[0][0].url.should.eql 'https://my-s3-bucket.s3.amazonaws.com'
      @fileupload.args[0][0].type.should.eql 'POST'
      @fileupload.args[0][0].dataType.should.eql 'xml'
      @fileupload.args[0][0].autoUpload.should.eql true

    describe 'file input id', ->
      it 'does not assigns the file input id when el does not have the file-input-id data attribute', ->
        _.isUndefined(@view.$el.find('input[name="file"]').attr('id')).should.be.ok

      it 'assigns the file input id with file-input-id data attribute of the el', ->
        $('body').attr 'data-file-input-id', 'image-upload'
        view = new @UploadForm el: $('body')
        view.$el.find('input[name="file"]').attr('id').should.equal 'image-upload'

    describe 'on add', ->
      beforeEach ->
        @ajax = sinon.stub $, 'ajax'
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
