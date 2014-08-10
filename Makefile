#
# Make -- the OG build tool.
# Add any build tasks here and abstract complex build scripts into `lib` that
# can be run in a Makefile task like `coffee lib/build_script`.
#
# Remember to set your text editor to use 4 size non-soft tabs.
#

BIN = node_modules/.bin

# Start the server
s:
	$(BIN)/coffee index.coffee

# Start the server pointing to staging
ss:
	APPLICATION_NAME=rudy-staging API_URL=http://stagingapi.takoman.co $(BIN)/coffee index.coffee

# Start the server pointing to production
sp:
	APPLICATION_NAME=rudy-production API_URL=http://api.takoman.co $(BIN)/coffee index.coffee

# Start the server monitored by pm2
# Pass the mode in the `env` environment variable, for example,
# 	`env=staging make spm2`      # Run Rudy in staging mode
# 	`env=production make spm2`   # Run Rudy in production mode
# TODO: Need to check the `env` env var
spm2:
	$(BIN)/pm2 ping
	RUNNING_RUDY=$$($(BIN)/pm2 list | grep rudy-$(env) -c); \
	case $$RUNNING_RUDY in \
	  0) echo "Starting rudy $(env)..."; RUDY_ENV=$(env) $(BIN)/pm2 start index.coffee --name rudy-$(env) ;; \
	  1) echo "Reloading rudy $(env)..."; RUDY_ENV=$(env) $(BIN)/pm2 reload index.coffee --name rudy-$(env) ;; \
	  *) echo "$$RUNNING_RUDY instances of rudy-$(env) is running. Looks like something went wrong?" ;; \
	esac; \

# Run all of the project-level tests, followed by app-level tests
test: assets
	$(BIN)/mocha $(shell find test -name '*.coffee' -not -path 'test/helpers/*')
	$(BIN)/mocha $(shell find components/*/test -name '*.coffee' -not -path 'test/helpers/*')
	$(BIN)/mocha $(shell find components/**/*/test -name '*.coffee' -not -path 'test/helpers/*')
	$(BIN)/mocha $(shell find apps/*/test -name '*.coffee' -not -path 'test/helpers/*')

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

.PHONY: test assets
