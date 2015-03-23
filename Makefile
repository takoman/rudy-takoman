#
# Make -- the OG build tool.
# Add any build tasks here and abstract complex build scripts into `lib` that
# can be run in a Makefile task like `coffee lib/build_script`.
#
# Remember to set your text editor to use 4 size non-soft tabs.
#

BIN = node_modules/.bin
CDN_DOMAIN_production = d2timokq6uoxgq
CDN_DOMAIN_staging = d2timokq6uoxgq

# Start the server
s:
	foreman start

# Start the server pointing to staging
ss:
	API_URL=http://stagingapi.takoman.co foreman start

# Start the server pointing to production
sp:
	API_URL=http://api.takoman.co foreman start

# Start the server with forever
# Stop (anyway and ignore errors) and start the app again, because forever
# does not support reloading env vars via `restart` yet.
# https://github.com/foreverjs/forever/issues/116#issuecomment-67889564
sf:
	-$(BIN)/forever stop rudy
	foreman run $(BIN)/forever start --uid "rudy" --append $(BIN)/coffee index.coffee

# Start the server with CDN monitored by pm2
# Pass the mode in the `env` environment variable, for example,
# 	`env=staging make spm2`      # Run Rudy in staging mode
# 	`env=production make spm2`   # Run Rudy in production mode
spm2: check-env cdn-assets
	$(BIN)/pm2 ping
	RUNNING_RUDY=$(shell $(BIN)/pm2 list | grep rudy -c); \
	case $$RUNNING_RUDY in \
	  0) echo "Starting rudy $(env)..."; RUDY_ENV=$(env) $(BIN)/pm2 start index.coffee --name rudy-$(env) ;; \
	  1) echo "Reloading rudy $(env)..."; RUDY_ENV=$(env) $(BIN)/pm2 reload index.coffee --name rudy-$(env) ;; \
	  *) echo "$$RUNNING_RUDY instances of rudy-$(env) is running. Abort."; exit 1; \
	esac; \

# Run all of the project-level tests, followed by app-level tests
test: assets lint
	$(BIN)/mocha $(shell find test -name '*.coffee' -not -path 'test/helpers/*')
	$(BIN)/mocha $(shell find components/*/test -name '*.coffee' -not -path 'test/helpers/*')
	$(BIN)/mocha $(shell find components/**/*/test -name '*.coffee' -not -path 'test/helpers/*')
	$(BIN)/mocha $(shell find apps/*/test -name '*.coffee' -not -path 'test/helpers/*')

# Run Coffeelint to check coffeescript styles
lint:
	$(BIN)/coffeelint $(shell find . -name '*.coffee' -not -path './node_modules/*')

# Generate minified assets from the /assets folder and output it to /public.
assets:
	mkdir -p public/assets
	$(foreach file, $(shell find assets -name '*.coffee' | cut -d '.' -f 1), \
		$(BIN)/browserify $(file).coffee -t jadeify -t caching-coffeeify > public/$(file).js; \
		$(BIN)/uglifyjs public/$(file).js > public/$(file).min.js; \
	)
	$(BIN)/stylus assets -o public/assets
	$(foreach file, $(shell find assets -name '*.styl' | cut -d '.' -f 1), \
		$(BIN)/sqwish public/$(file).css -o public/$(file).min.css; \
	)

# Generate minified assets and upload them to CDN.
# Pass the mode in the `env` environment variable to use different bucket, e.g.
# 	`env=staging make cdn-assets`      # Compile and upload assets to the staging bucket
# 	`env=production make cdn-assets`   # Compile and upload assets to the production bucket
cdn-assets: check-env assets
	$(BIN)/bucket-assets

check-env:
ifndef env
	$(error Environment variable `env` is undefined.)
endif

.PHONY: s ss sp spm2 test lint assets cdn-assets check-env
