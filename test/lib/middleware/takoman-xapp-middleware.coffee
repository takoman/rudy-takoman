sinon   = require 'sinon'
express = require 'express'
request = require 'superagent'
moment  = require 'moment'
takomanXappMiddleware = require '../../../lib/middleware/takoman-xapp-middleware'

# Fake api server
api = express()
api.get '/api/v1/xapp_token', (req, res, next) ->
  res.send { xapp_token: 'x-foo-token', expires_in: moment().add('seconds', 2).format() }

# App server
app = express()
app.use takomanXappMiddleware
  apiUrl: 'http://localhost:4001'
  clientId: 'fooid'
  clientSecret: 'foosecret'
app.get '/foo', (req, res) ->
  res.send res.locals.takomanXappToken

describe 'takomanXappMiddleware', ->

  before (done) ->
    api.listen 4001, ->
      app.listen 4000, ->
        done()

  it 'fetches an xapp token and stores it in the request', (done) ->
    request('http://localhost:4000/foo').end (res) ->
      res.text.should.equal 'x-foo-token'
      done()

  it 'injects the cached token on subsequent requests', (done) ->
    request('http://localhost:4000/foo').end (res) ->
      res.text.should.equal 'x-foo-token'
      done()

  it 'expires the token after the expiration time', (done) ->
    request('http://localhost:4000/foo').end (res) ->
      res.text.should.equal 'x-foo-token'
      setTimeout ->
        (takomanXappMiddleware.token?).should.not.be.ok
        done()
      , 2000
