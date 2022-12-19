screenLib = require "screenLib"

function updateLibs()
    screenLib.update()
end

UI.Hide(true)
UI.StopUpdate(true)
Arena.Hide()
Player.SetControlOverride(true)

buttonArray = screenLib.createObjectArray(4, 3, 0, 0, 0, 0)

function Update()
    updateLibs()
end