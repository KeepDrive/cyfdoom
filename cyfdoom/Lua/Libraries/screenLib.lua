local defaultPosition = {0, 0}
local white = {1, 1, 1}

local buttonFont = "uidialog"
local buttonProgressMode = "none"
local buttonTextWidth = 100
local buttonLayer = "Top"
local buttonFunc = function()
    DEBUG("No function assigned")
end

local screenSizeX = 640
local screenSizeY = 480

local updatables = {}

local function setText(self, text)
    text = text or ""
    self.text.SetText("[instant]"..text)
end
local function buttonUpdate(self)
    local objectArray = self.parent
    local left = objectArray.left
    local right = objectArray.right
    local bottom = objectArray.bottom
    local top = objectArray.top
    self.text.x = left + (self.arrayX > 1 and (self.arrayX - 1) * (screenSizeX - right - left) / (#objectArray - 1) or 0)
    self.text.y = bottom + (self.arrayY > 1 and (self.arrayY - 1) * (screenSizeY - top - bottom) / (#objectArray[self.arrayX] - 1) or 0)
end

local function objectArrayUpdate(self)
    for x = 1, #self do
        for y = 1, #self[x] do
            self[x][y]:update()
        end
    end
end

local function createButton(func, text, position, layer)
    func = func or buttonFunc
    text = text or ""
    position = position or defaultPosition
    layer = layer or buttonLayer
    local buttonText = CreateText("[instant]"..text, position, buttonTextWidth, layer)
    buttonText.SetFont(buttonFont)
    buttonText.color = white
    buttonText.progressmode = buttonProgressMode
    buttonText.HideBubble()
    return {text = buttonText, setText = setText, update = buttonUpdate, func = func}
end

local function createObjectArray(sizeX, sizeY, left, right, bottom, top)
    left = left or 0
    right = right or 0
    bottom = bottom or 0
    top = top or 0
    local objectArray = {left = left, right = right, bottom = bottom, top = top, update = objectArrayUpdate}
    for x = 1, sizeX do
        objectArray[x] = {}
        for y = 1, sizeY do
            local button = createButton()
            objectArray[x][y] = {parent = objectArray, arrayX = x, arrayY = y}
        end
    end
    updatables[#updatables + 1] = objectArray
    return objectArray
end

local function update()
    for i = 1, #updatables do
        updatables[i]:update()
    end
end

return {
    createButton = createButton,
    createObjectArray = createObjectArray,
    update = update
}