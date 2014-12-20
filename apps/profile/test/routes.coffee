#
# Route tests. Exporting the route handlers into their own function
# makes testing straightforward. Because Backbone.sync acts as our layer
# of abstraction over HTTP, we use [sinon](http://sinonjs.org/) to stub it
# and return fake API responses instead of testing against the actual GitHub
# API, which would be slow and unpredictable.
#

routes = require "../routes"
Backbone = require "backbone"
sinon = require "sinon"

describe "#index", ->

  beforeEach ->
    sinon.stub Backbone, "sync"
    @req = {}
    @res =
      render: sinon.stub()
      locals: sd: {}

  afterEach ->
    Backbone.sync.restore()
