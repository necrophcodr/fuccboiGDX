local ui = {}

ui.style = require (mogamett_path .. '/libraries/mogamett/ui/styles/default')
ui.setStyle = function(style) ui.style = require (mogamett_path .. '/libraries/mogamett/ui/styles/' .. style) end

ui.input = mg.Input()
ui.input:bind('mouse1', 'mouse1')

ui.Button = require (mogamett_path .. '/libraries/mogamett/ui/Button')

return ui
