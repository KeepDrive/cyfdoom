require "math"
local min = math.min
local max = math.max

local defaultPosition = {0, 0}
local white = {1, 1, 1}
local grey = {0.5, 0.5, 0.5}
local yellow = {1, 1, 0}
local emptyFunction = function() end

local activeColour = white
local deactiveColour = grey
local focusedColour = yellow

local buttonFont = "uidialog"
local buttonProgressMode = "none"
local buttonTextWidth = 1000
local buttonLayer = "Top"
local buttonFunc = function()
    DEBUG("No function assigned")
end

local labelFont = "uidialog"
local labelProgressMode = "none"
local labelTextWidth = 1000
local labelLayer = "Top"

local screenSizeX = 640
local screenSizeY = 480

local updatables = {}

local function setText(self, text)
    text = text or ""
    self.text.SetText("[instant]"..text)
end
local function setFocus(self, x, y, focus)
    focus = focus or true
    self.focusedObject = self[x][y]
end
local function findAndMoveFocus(objArray, xMin, xMax, yMin, yMax, overflowHandler)
    if min(xMin, xMax) == 0 or min(yMin, yMax) == 0 or max(xMin, xMax) == #objArray + 1 or max(yMin, yMax) == #objArray[1] + 1 then
        overflowHandler(objArray)
        return
    end
    for y = yMin, yMax, yMax >= yMin and 1 or -1 do
        for x = xMin, xMax, xMax >= xMin and 1 or -1 do
            if objArray[x][y].active and objArray[x][y].func != nil then
                objArray:setFocus(x, y)
                return
            end
        end
    end
    overflowHandler(objArray)
end
local function defaultHandleLeftOverflow(objArray)
    local x = objArray.focusedObject.arrayX
    local y = objArray.focusedObject.arrayY
    findAndMoveFocus(objArray, #objArray, x + 1, y, y, emptyFunction)
end
local function defaultHandleRightOverflow(objArray)
    local x = objArray.focusedObject.arrayX
    local y = objArray.focusedObject.arrayY
    findAndMoveFocus(objArray, 1, x - 1, y, y, emptyFunction)
end
local function defaultHandleUpOverflow(objArray)
    local x = objArray.focusedObject.arrayX
    local y = objArray.focusedObject.arrayY
    findAndMoveFocus(objArray, x, x, #objArray[x], y + 1, emptyFunction)
end
local function defaultHandleDownOverflow(objArray)
    local x = objArray.focusedObject.arrayX
    local y = objArray.focusedObject.arrayY
    findAndMoveFocus(objArray, x, x, 1, y - 1, emptyFunction)
end
local function moveFocusLeft(objArray)
    local x = objArray.focusedObject.arrayX
    local y = objArray.focusedObject.arrayY
    findAndMoveFocus(objArray, x - 1, 1, y, y, objArray.handleLeftOverflow)
end
local function moveFocusRight(objArray)
    local x = objArray.focusedObject.arrayX
    local y = objArray.focusedObject.arrayY
    findAndMoveFocus(objArray, x + 1, #objArray, y, y, objArray.handleRightOverflow)
end
local function moveFocusUp(objArray)
    local x = objArray.focusedObject.arrayX
    local y = objArray.focusedObject.arrayY
    findAndMoveFocus(objArray, x, x, y - 1, 1, objArray.handleUpOverflow)
end
local function moveFocusDown(objArray)
    local x = objArray.focusedObject.arrayX
    local y = objArray.focusedObject.arrayY
    findAndMoveFocus(objArray, x, x, y + 1, #objArray[x], objArray.handleDownOverflow)
end
local function defaultControls(self)
    if Input.Right == 1 then
        moveFocusRight(self)
    elseif Input.Left == 1 then
        moveFocusLeft(self)
    end
    if Input.Up == 1 then
        moveFocusUp(self)
    elseif Input.Down == 1 then
        moveFocusDown(self)
    end
    if Input.Confirm == 1 then
        self.focusedObject:func()
    end
end

local function textUpdate(self)
    local objectArray = self.parent
    local left = objectArray.left
    local right = objectArray.right
    local bottom = objectArray.bottom
    local top = objectArray.top
    self.text.x = left + (self.arrayX > 1 and (self.arrayX - 1) * (screenSizeX - right - left) / (#objectArray - 1) or 0)
    self.text.y = screenSizeY - top - (self.arrayY > 1 and (self.arrayY - 1) * (screenSizeY - top - bottom) / (#objectArray[self.arrayX] - 1) or 0)
    self.text.color = self.active and activeColour or deactiveColour
end
local function buttonUpdate(self)
    textUpdate(self)
    if self.parent.focusedObject == self then
        self.text.color = focusedColour
    end
end
local function objectArrayUpdate(self)
    for x = 1, #self do
        for y = 1, #self[x] do
            if self[x][y].update != nil then
                self[x][y]:update()
            end
        end
    end
    if self.active then
        self:handleControls()
    end
end

local function createLabel(self, x, y, text, position, layer)
    text = text or ""
    position = position or defaultPosition
    layer = layer or labelLayer
    local labelText = CreateText("", position, labelTextWidth, layer)
    labelText.SetFont(labelFont)
    labelText.progressmode = labelProgressMode
    labelText.HideBubble()
    self[x][y] = {
        parent = self, arrayX = x, arrayY = y, active = true, text = labelText,
        setText = setText, update = textUpdate
    }
    self[x][y]:setText(text)
end

local function createButton(self, x, y, func, text, position, layer)
    func = func or buttonFunc
    text = text or ""
    position = position or defaultPosition
    layer = layer or buttonLayer
    local buttonText = CreateText("", position, buttonTextWidth, layer)
    buttonText.SetFont(buttonFont)
    buttonText.progressmode = buttonProgressMode
    buttonText.HideBubble()
    self[x][y] = {
        parent = self, arrayX = x, arrayY = y, active = true, text = buttonText,
        setText = setText, update = buttonUpdate, func = func
    }
    self[x][y]:setText(text)
end

local function createObjectArray(sizeX, sizeY, left, right, bottom, top)
    left = left or 0
    right = right or 0
    bottom = bottom or 0
    top = top or 0
    local objectArray = {
        left = left, right = right, bottom = bottom, top = top, active = true, focusedObject = nil,
        createButton = createButton, createLabel = createLabel, setFocus = setFocus,
        handleLeftOverflow = defaultHandleLeftOverflow, handleRightOverflow = defaultHandleRightOverflow,
        handleUpOverflow = defaultHandleUpOverflow, handleDownOverflow = defaultHandleDownOverflow,
        handleControls = defaultControls, update = objectArrayUpdate
    }
    for x = 1, sizeX do
        objectArray[x] = {}
        for y = 1, sizeY do
            objectArray[x][y] = {}
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
    createObjectArray = createObjectArray,
    update = update
}