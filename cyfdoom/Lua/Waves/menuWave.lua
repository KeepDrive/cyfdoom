screenLib = require "screenLib"

function updateLibs()
    screenLib.update()
end

UI.Hide(true)
UI.StopUpdate(true)
Arena.Hide()
Player.SetControlOverride(true)

labels = {"test1", "test2", "test3", "test4", "test5", "test6", "test7", "test8"}
local firstLabel = 1

local objArraySizeX = 2
local objArraySizeY = 7
objArray = screenLib.createObjectArray(objArraySizeX, objArraySizeY, 120, 120, 120, 120)
objArray:createButton(2, 1, nil, "Refresh")
for y = 2, objArraySizeY do
    objArray:createLabel(1, y, labels[firstLabel + y - 2] or "-empty-")
    objArray:createButton(2, y, nil, "Play")
    if labels[y - 1] == nil then
        objArray[1][y].active = false
        objArray[2][y].active = false
    end
end
objArray:setFocus(2, objArray[2][2].active and 2 or 1)
local function relabel()
    for y = 2, #objArray[1] do
        objArray[1][y]:setText(labels[firstLabel + y - 2] or "-empty-")
    end
end
local function moveLabelsDown(objArray)
    firstLabel = firstLabel + 1
    local maxLabel = #labels - #objArray[1] + 2
    maxLabel = maxLabel > 0 and maxLabel or 1
    if firstLabel > maxLabel then
        firstLabel = 1
        objArray:setFocus(2, 1)
    end
    relabel()
end
local function moveLabelsUp(objArray)
    firstLabel = firstLabel - 1
    local maxLabel = #labels - #objArray[1] + 2
    maxLabel = maxLabel > 0 and maxLabel or 1
    if firstLabel < 1 then
        firstLabel = maxLabel
        objArray:setFocus(2, #objArray[2])
    end
    relabel()
end
function objArray.handleDownOverflow(self)
    moveLabelsDown(self)
    objArray[2][1].active = firstLabel == 1
end
function objArray.handleUpOverflow(self)
    moveLabelsUp(self)
    objArray[2][1].active = firstLabel == 1
end

function Update()
    updateLibs()
end