#
# Main app file that runs setup code and starts the server process.
# This code should be kept to a minimum. Any setup code that gets large should
# be abstracted into modules under /lib.
#

{ PORT, NODE_ENV } = require "./config"

# Require New Relic as the first line of the app's main module.
# TODO: Disable New Relic for now, until the memory leak issues have resolved.
# require 'newrelic' unless NODE_ENV is 'development'

express = require "express"
setup = require "./lib/setup"

app = module.exports = express()
setup app

# Start the server and send a message to IPC for the integration test
# helper to hook into.
app.listen PORT, ->
  console.log "Rudy #{NODE_ENV} listening on port " + PORT
  process.send? "listening"
