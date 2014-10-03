local ui = {}

ui.style = require (mogamett_path .. '/libraries/mogamett/ui/styles/mogamett')
ui.setStyle = function(style) ui.style = require (mogamett_path .. '/libraries/mogamett/ui/styles/' .. style) end

ui.input = mg.Input()
ui.input:bind('mouse1', 'mouse1')
ui.input:bind('return', 'return')
ui.input:bind('tab', 'select')
ui.input:bind('backspace', 'backspace')

ui.Button = require (mogamett_path .. '/libraries/mogamett/ui/Button')
ui.Element = require (mogamett_path .. '/libraries/mogamett/ui/Element')
ui.Frame = require (mogamett_path .. '/libraries/mogamett/ui/Frame')
ui.Checkbox = require (mogamett_path .. '/libraries/mogamett/ui/Checkbox')
ui.Textfield = require (mogamett_path .. '/libraries/mogamett/ui/Textfield')

return ui
