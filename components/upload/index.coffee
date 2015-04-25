_ = require 'underscore'
mime = require 'mime'
uuid = require 'node-uuid'
crypto = require 'crypto'
moment = require 'moment'

opts =
  s3Key: ''
  s3Secret: ''
  s3Bucket: ''
  s3UploadDir: 'uploads'
  maxFileSize: 5242880   # 5MB limit

module.exports = (options) ->
  _.extend opts, options
  module.exports

module.exports.s3UploadFormData = (req, res) ->
  mimeType = mime.lookup req.query.filename
  extension = mime.extension mimeType
  expire = moment.utc().add(1, 'hour').toISOString()  # 2015-04-11T04:26:35.983Z
  filename = "#{uuid.v4()}.#{extension}"              # 998c3b1c-ab87-456e-88f8-fb827ce4f413.png
  filepath = "#{opts.s3UploadDir}/#{filename}"

  policy = JSON.stringify(
    'expiration': expire
    'conditions': [
      { 'bucket': opts.s3Bucket }
      [ 'eq', '$key', filepath ]
      { 'acl': 'public-read' }
      { 'success_action_status': '201' }
      [ 'starts-with', '$Content-Type', mimeType ]
      [ 'content-length-range', 0, opts.maxFileSize ]
    ]
  )
  base64policy = new Buffer(policy).toString('base64')
  signature = crypto.createHmac('sha1', opts.s3Secret).update(base64policy).digest('base64')
  res.json
    key: filepath               # path stored on S3
    awsAccessKeyId: opts.s3Key  # S3 key
    acl: 'public-read'
    policy: base64policy
    signature: signature
    contentType: mimeType
