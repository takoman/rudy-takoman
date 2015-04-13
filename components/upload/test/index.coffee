_ = require 'underscore'
sinon = require 'sinon'
rewire = require 'rewire'

describe 'S3 upload middleware', ->
  describe 'initialization', ->
    beforeEach ->
      @S3Upload = rewire '../index'

    it 'overrides the default options with options passed in', ->
      options =
        s3Key: 'overriding-key'
        s3Secret: 'overriding-secret'
        s3Bucket: 'overriding-bucket'
        s3UploadDir: 'overriding-dir'
        maxFileSize: 1024
      upload = @S3Upload options
      upload.__get__('opts').should.eql options

  describe '#s3UploadFormData', ->
    beforeEach ->
      @S3Upload = rewire '../index'
      @req = { query: { filename: '' } }
      @res = { json: sinon.stub() }
      upload = @S3Upload()
      upload.s3UploadFormData(@req, @res)

    it 'returns json response', ->
      @res.json.calledOnce.should.be.ok

    it 'returns json response with necessary fields', ->
      @res.json.args[0][0].should.have.keys(
        ['key', 'awsAccessKeyId', 'acl', 'policy', 'signature', 'contentType']
      )
