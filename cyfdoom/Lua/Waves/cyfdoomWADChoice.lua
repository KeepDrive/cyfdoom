local max = math.max
local min = math.min
local floor = math.floor

local white = {1, 1, 1}
local yellow = {1, 1, 0}

local bgLayer = "Top"
local textLayer = "Top"

local bgImage = "cyfdoomMenuDesign"

local wadNotFoundString = "[instant][font:uidialog]No WADs found in the WADs folder.\nPlease make sure that your WADs are in the correct folder and are readable.\nThen press refresh or reload cyfDoom."

local maxWADsVisible = 6

local function getWADs()
    local WADs = Misc.ListDir("WADs")
    for i = #WADs, 1, -1 do
        local WADType = Misc.OpenFile("WADs\\"..WADs[i], 'r').ReadLine(1):sub(1,4)
        if WADType ~= "IWAD" and WADType ~= "PWAD" then
            table.remove(WADs, i)
        end
    end
    return WADs
end

local WADList = {}

local lastVisibleWAD = 0

local bgSprite = CreateSprite(bgImage, bgLayer)
bgSprite.Scale(2, 2)

local titles = {}

local function createTitle(titleText, position)
    local titleTextWidth = min(320, position[1])
    local newTitle = CreateText("[instant][font:uidialog]"..titleText, position, titleTextWidth, textLayer)
    newTitle.x = newTitle.x - newTitle.getTextWidth()
    newTitle.color = {1, 1, 1}
    newTitle.progressmode = "none"
    newTitle.HideBubble()
    titles[#titles + 1] = newTitle
end

local function getOnScreenTitleByIndex(index, WADIndex)
    WADIndex = WADIndex or lastVisibleWAD
    local WADsAmt = #WADList
    return WADList[(WADsAmt + (WADIndex - maxWADsVisible + index) - 1) % WADsAmt + 1]
end

local function processTitleString(titleString)
    for j = #titleString, 1, -1 do
        if titleString:sub(j, j) == '.' then
            titleString = titleString:sub(1, j - 1)
            break
        end
    end
    return titleString
end

local function refreshTitles(WADIndex)
    WADIndex = WADIndex or lastVisibleWAD
    for i = #titles, 1, -1 do
        local newTitle = titles[i]
        newTitle.x = newTitle.x + newTitle.getTextWidth()
        newTitle.SetText("[instant][font:uidialog]"..processTitleString(getOnScreenTitleByIndex(i, WADIndex)))
        newTitle.x = newTitle.x - newTitle.getTextWidth()
    end
end

local buttons = {}

local function createButton(buttonText, position)
    local buttonTextWidth = 100
    local newButton = CreateText("[instant][font:uidialog]"..buttonText, position, buttonTextWidth, textLayer)
    newButton.color = {1, 1, 1}
    newButton.progressmode = "none"
    newButton.HideBubble()
    buttons[#buttons + 1] = newButton
end

createButton("Refresh", {400, 346})

local function refreshWADs()
    if wadNotFoundText ~= nil then
        wadNotFoundText.Remove()
    end
    while #buttons > 1 do
        buttons[#buttons].Remove()
        table.remove(buttons, #buttons)
    end
    while #titles > 0 do
        titles[#titles].Remove()
        table.remove(titles, #titles)
    end
    WADList = getWADs()
    if #WADList == 0 then
        wadNotFoundText = CreateText(wadNotFoundString, {60, 300}, 520, bgLayer)
        wadNotFoundText.color = {0.5, 0.5, 0.5}
        wadNotFoundText.progressmode = "none"
        wadNotFoundText.HideBubble()
    else
        lastVisibleWAD = min(maxWADsVisible, #WADList)
        for i = 0, lastVisibleWAD - 1 do
            local wadTitle = processTitleString(WADList[i + 1])
            createTitle(wadTitle, {315, 300 - i * 40})
            createButton("Play", {400, 300 - i * 40})
            createButton("Options", {475, 300 - i * 40})
        end
    end
end

local function endChoicer()
    Encounter["nextwaves"] = {"cyfdoomMain"}
    bgSprite.Remove()
    for i = #buttons, 1, -1 do
        buttons[i].Remove()
    end
    buttons = nil
    for i = #titles, 1, -1 do
        titles[i].Remove()
    end
    titles = nil
    EndWave()
    Encounter.Call("State", {"DEFENDING"})
end

local selectedButton = 1

local function processControls()
    buttons[selectedButton].color = white

    if Input.Up == 1 then
        if (selectedButton == 2 or selectedButton == 3) and lastVisibleWAD > maxWADsVisible then
            lastVisibleWAD = lastVisibleWAD - 1
            refreshTitles()
        else
            selectedButton = selectedButton - 2
        end
    end
    if Input.Down == 1 then
        selectedButton = selectedButton + (selectedButton == 1 and 1 or 2)
    end
    
    if (Input.Left == 1 or Input.Right == 1) and selectedButton ~= 1 then
        selectedButton = selectedButton - selectedButton % 2 + (selectedButton + 1) % 2
    end

    if selectedButton < 0 then
        selectedButton = max(1, #buttons - 1)
        lastVisibleWAD = #WADList
        refreshTitles()
    elseif selectedButton == 0 then
        selectedButton = 1
    elseif selectedButton > #buttons then
        if lastVisibleWAD >= #WADList then
            selectedButton = 1
            lastVisibleWAD = maxWADsVisible
            refreshTitles()
        else
            lastVisibleWAD = lastVisibleWAD + 1 
            refreshTitles()
            selectedButton = selectedButton - 2
        end
    end

    if Input.Confirm == 1 then
        if selectedButton == 1 then
            refreshWADs()
        elseif selectedButton % 2 == 0 then
            Encounter.SetVar("wadFileName", getOnScreenTitleByIndex(selectedButton / 2))
            endChoicer()
        end
    end
    if buttons ~= nil then
        buttons[selectedButton].color = yellow
    end
end

refreshWADs()

function Update()
    processControls()
end