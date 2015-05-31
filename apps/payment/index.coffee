express = require 'express'
routes = require './routes'

app = module.exports = express()
app.set 'views', __dirname + '/templates'
app.set 'view engine', 'jade'

#app.post '/invoices/:id/payment-callback', routes.paymentCallback
#app.post '/invoices/:id/online-payment-redirected', routes.offlinePaymentRedirected
app.post '/invoices/:id/offline-payment-redirected', routes.offlinePaymentRedirected
app.get '/invoices/:id/payment-confirmation', routes.paymentConfirmation
