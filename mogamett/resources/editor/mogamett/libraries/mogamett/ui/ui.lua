local ui = {}

ui.style = require (mogamett_path .. '/libraries/mogamett/ui/styles/mogamett')
ui.setStyle = function(style) ui.style = require (mogamett_path .. '/libraries/mogamett/ui/styles/' .. style) end

ui.input = mg.Input()
ui.input:bind('mouse1', 'activate')
ui.input:bind('return', 'activate')
ui.input:bind('tab', 'select')

ui.Button = require (mogamett_path .. '/libraries/mogamett/ui/Button')
ui.Element = require (mogamett_path .. '/libraries/mogamett/ui/Element')
ui.Frame = require (mogamett_path .. '/libraries/mogamett/ui/Frame')
ui.Checkbox = require (mogamett_path .. '/libraries/mogamett/ui/Checkbox')

return ui
