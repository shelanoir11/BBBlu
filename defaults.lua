defaults = {}
defaults.display = {}
defaults.display.pos = {}
defaults.display.pos.x = 0
defaults.display.pos.y = 0
defaults.display.padding = 8

-- custom colors for spell statuses
defaults.colors = {}
defaults.colors.learned = {red = 128, green = 128, blue = 128}
defaults.colors.unlearned = {red = 255, green = 255, blue = 255}
defaults.colors.cant_learn = {red = 255, green = 100, blue = 100}

defaults.display.bg = {}
defaults.display.bg.red = 20
defaults.display.bg.green = 20
defaults.display.bg.blue = 20
defaults.display.bg.alpha = 180 

defaults.display.text = {}
defaults.display.text.font = 'Montserrat'
defaults.display.text.red = 255
defaults.display.text.green = 255
defaults.display.text.blue = 255
defaults.display.text.alpha = 255
defaults.display.text.size = 11

-- adds a 1-pixel black outline to all text for readability
defaults.display.text.stroke = {}
defaults.display.text.stroke.width = 1
defaults.display.text.stroke.alpha = 255
defaults.display.text.stroke.red = 0
defaults.display.text.stroke.green = 0
defaults.display.text.stroke.blue = 0

-- radar settings
defaults.radar = table.copy(defaults.display)
defaults.radar.pos.x = 300 
defaults.radar.pos.y = 200
defaults.radar.track_learnable = true
defaults.radar.track_unlearnable = true

return defaults