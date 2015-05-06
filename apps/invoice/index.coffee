#
# The express app for the 'invoice' app.
#

express = require 'express'
routes = require './routes'

app = module.exports = express()
app.set 'views', __dirname + '/templates'
app.set 'view engine', 'jade'
app.get '/invoices/:id', routes.index
app.get '/invoices/:id/shipping', routes.shipping
