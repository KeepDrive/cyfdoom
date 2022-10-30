local char = string.char
local concat = table.concat

wadString = ""
local strPtr = 1

readers = {
    uint = function()
        local bytes = {wadString:byte(strPtr, strPtr + 3)}
        strPtr = strPtr + 4
        return bytes[4] * 16777216 + bytes[3] * 65536 + bytes[2] * 256 + bytes[1]
    end,
    str = function(strLen)
        strPtr = strPtr + strLen
        return wadString:sub(strPtr - strLen, strPtr - 1) -- This might return the string with padding, will have to change if that is the case
    end,
    wad = function(wadFileName)
        wadString = concat(Misc.OpenFile("WADs/"..wadFileName, 'r').ReadLines(), '\n') -- Thankfully the separator seems to consistently be LF
        local numlumps = readers.uint()
        local infotableofs = readers.uint()
        strPtr = infotableofs + 1
        local lumps = {}
        for i = 1, (wadString:len() - infotableofs)/16 do
            lumps[i] = readers.lump()
        end
        wadString = nil
        return lumps
    end,
    lump = function() return {readers.uint(), readers.uint(), readers.str(8)} end
}

return readers