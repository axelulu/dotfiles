local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
  topmost = "window",
	position = "bottom",
  height = 40,
  color = colors.bar.bg,
  margin = 4,
  padding_right = 2,
  padding_left = 2,
})
