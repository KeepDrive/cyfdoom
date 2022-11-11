local char = string.char
local concat = table.concat

local WADFileName = Encounter.GetVar("WADFileName")

local yellow = {1, 1, 0}
local white = {1, 1, 1}
local black = {0, 0, 0}

local bg = CreateSprite("bg", "Top")
bg.Scale(2, 2)
bg.color = black

local readers = require "reader"

local warningText = nil
local yesButton = nil
local noButton = nil

local read = coroutine.create(function()
    if not pcall(Misc.OpenFile, "WADs/Converted/"..WADFileName, 'r') then
        warningText = CreateText("[instant][font:uidialog]This WAD needs to be converted to a readable format before being used. This process is automatic and only needs to be done once.\n\n[color:ff0000]Warning:[color] this uses a lot of RAM (>4GB), if you do not have enough RAM please use the converter Python script provided with cyfDOOM first instead.\n\nDo you wish to proceed?", {20, 440}, 600, "Top")
        warningText.color = white
        warningText.progressmode = "none"
        warningText.HideBubble()
        yesButton = CreateText("[instant][font:uidialog]Yes", {220, 100}, 300, "Top")
        yesButton.color = white
        yesButton.progressmode = "none"
        yesButton.HideBubble()
        noButton = CreateText("[instant][font:uidialog]No", {420, 100}, 300, "Top")
        noButton.color = white
        noButton.progressmode = "none"
        noButton.HideBubble()
        coroutine.yield(1)
        local WADBytes = Misc.OpenFile("WADs/"..WADFileName, 'r').ReadBytes()
        for i = 1, #WADBytes do
            WADBytes[i] = char(WADBytes[i])
        end
        local WADString = concat(WADBytes)
        WADBytes = nil
        Misc.OpenFile("WADs/Converted/"..WADFileName, 'w').Write(WADString, false)
        WADString = nil
        warningText.SetText("[instant][font:uidialog]Done.\nFor some reason CYF does not seem to release the RAM used for reading binary files(even after exiting the mod), so you might want to restart CYF instead of proceeding.\nProceed anyway?")
        coroutine.yield(2)
    end
    coroutine.yield(0)
    lumps = readers.WAD(WADFileName)
end
)
local status = nil
local code = -1
local choice = 0
function Update()
    if code == -1 then
        status, code = coroutine.resume(read)
    elseif code ~= 0 then
        if choice == 0 then
            yesButton.color = yellow
            noButton.color = white
        else
            yesButton.color = white
            noButton.color = yellow
        end
        if Input.Left == 1 or Input.Right == 1 then
            choice = 1 - choice
        end
        if Input.Confirm == 1 then
            if choice == 0 then
                if code == 1 then
                    warningText.SetText("[instant][font:uidialog]Hold on. This might take a minute...")
                    yesButton.color = black
                    noButton.color = black
                    code = -1
                else
                    warningText.Remove()
                    yesButton.Remove()
                    noButton.Remove()
                    code = -1
                end
            else
                State("Done")
            end
        end
    end
end