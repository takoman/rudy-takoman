#
# Tests for the client-side code of the commits app. Because
# [Browserify](https://github.com/substack/node-browserify) allows us to
# write our client-side in modules, testing becomes a lot easier. There are
# still some obstacles to unit testing client-side code such as not having
# a DOM available. In this case we use [benv](https://github.com/artsy/benv)
# to create a more suitable environment for unit testing client-side code in
# node.js.
#

benv = require("benv")
sinon = require("sinon")
Backbone = require("backbone")
Commits = require("../../../collections/commits")
resolve = require("path").resolve

describe "ProfileView", ->
  undefined
