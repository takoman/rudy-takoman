#
# The javscript asset package for the "profile" app.
#
# It's a good pattern to organize your asset packages by a package per app.
# This generally means these javascript asset files are going to be quite
# small, often just a line of initialize code like this.
#

require('backbone').$ = $
$ require("../apps/profile/client.coffee").init
