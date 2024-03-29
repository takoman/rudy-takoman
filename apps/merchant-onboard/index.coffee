#
# The express app for the "merchant" app.
#
# Simply exports the express instance to be mounted into the project,
# and loads the routes.
#

express = require 'express'
routes = require './routes'

app = module.exports = express()
app.set 'views', __dirname + '/templates'
app.set 'view engine', 'jade'
app.get '/merchants/new', routes.new
