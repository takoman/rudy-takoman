#
# Routes file that exports route handlers for ease of testing.
#

@index = (req, res, next) ->
  colors =
    "gray-lightest"    : "#efefef"
    "gray-lighter"     : "#e5e5e5"
    "gray-light"       : "#dbdbdb"
    "gray"             : "#cccccc"
    "gray-dark"        : "#999999"
    "gray-darker"      : "#666666"
    "gray-darkest"     : "#333333"
    "red"              : "#fd5650"
    "navy"             : "#3f5562"
    "white"            : "#fff"
    "black"            : "#000"
    "brand-primary"    : "#fd5650"
    "brand-secondary"  : "#3f5562"

  res.render 'index', colors: colors
