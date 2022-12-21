require "math"
local min = math.min
local screenLib = require "screenLib"
local fileLib = require "fileLib"

local function updateLibs()
    screenLib.update()
end

screenLib.disableDefaultUI()

local labels = {}
local firstLabel = 1

local objArraySizeX = 2
local objArraySizeY = 7
objArray = screenLib.createObjectArray(objArraySizeX, objArraySizeY, 120, 120, 120, 120)
local function playButton(self)
    local WADName = self.parent[1][self.arrayY].text
    Encounter.SetVar("WADName", fileLib.getWAD(WADName))
    objArray = objArray:destroy()
    EndWave()
end
for y = 2, objArraySizeY do
    local label = objArray:createLabel(1, y, labels[firstLabel + y - 2] or "-empty-")
    local button = objArray:createButton(2, y, playButton, "Play")
end

local function relabel()
    for y = 2, objArraySizeY do
        objArray[1][y]:setText(labels[firstLabel + y - 2] or "-empty-")
    end
end

local function refreshWADs()
    labels = fileLib.getWADs()
    for i = 2, objArraySizeY do
        objArray[1][i].active = (i - 1 <= #labels)
        objArray[2][i].active = (i - 1 <= #labels)
    end
    relabel()
end
refreshWADs()
local refreshButton = objArray:createButton(2, 1, refreshWADs, "Refresh")

objArray:setFocus(2, objArray[2][2].active and 2 or 1)

local function getMaxLabel()
    local maxLabel = #labels - objArraySizeY + 2
    return maxLabel > 0 and maxLabel or 1
end
local function moveLabelsDown(objArray)
    firstLabel = firstLabel + 1
    if firstLabel > getMaxLabel() then
        firstLabel = 1
    end
    relabel()
end
local function moveLabelsUp(objArray)
    firstLabel = firstLabel - 1
    if firstLabel < 1 then
        firstLabel = getMaxLabel()
    end
    relabel()
end
function objArray.handleDownOverflow(self)
    moveLabelsDown(self)
    if firstLabel == 1 then
        objArray:setFocus(2, 1)
    end
    refreshButton.active = (firstLabel == 1)
end
function objArray.handleUpOverflow(self)
    moveLabelsUp(self)
    local maxLabel = getMaxLabel()
    if firstLabel == maxLabel then
        objArray:setFocus(2, min(objArraySizeY, #labels + 1))
    end
    refreshButton.active = (firstLabel == 1)
end

function Update()
    updateLibs()
end