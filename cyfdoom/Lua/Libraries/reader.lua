WADString = ""
local strPtr = 1

readers = {
    uint = function()
        local bytes = {WADString:byte(strPtr, strPtr + 3)}
        strPtr = strPtr + 4
        return bytes[4] * 16777216 + bytes[3] * 65536 + bytes[2] * 256 + bytes[1]
    end,
    str = function(strLen)
        strPtr = strPtr + strLen
        return WADString:sub(strPtr - strLen, strPtr - 1) -- This might return the string with padding, will have to change if that is the case
    end,
    WAD = function(WADFileName)
        local identification = readers.str(4)
        local numlumps = readers.uint()
        local infotableofs = readers.uint()
        DEBUG(identification)
        DEBUG(numlumps)
        DEBUG(infotableofs)
        strPtr = infotableofs + 1
        local lumps = {}
        for i = 1, numlumps do
            lumps[i] = readers.lump()
        end
        WADString = nil
        return lumps
    end,
    lump = function() return {readers.uint(), readers.uint(), readers.str(8)} end
}

return readers