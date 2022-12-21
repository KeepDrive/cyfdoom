local WADsDirectory = "WADs"

local function listFilesRecursively(directory)
    local files = Misc.ListDir(directory, false)
    local directories = Misc.ListDir(directory, true)
    for i = 1, #directories do
        local subFiles = listFilesRecursively(directory.."/"..directories[i])
        for j = 1, #subFiles do
            files[#files + 1] = directories[i].."/"..subFiles[j]
        end
    end
    return files
end

local function isWADValid(WADFile)
    WADFile = Misc.OpenFile(WADFile, "r")
    local header = WADFile.ReadLine(1):sub(1,4)
    return (header == "IWAD") or (header == "PWAD")
end

local function getWADs()
    if not Misc.DirExists(WADsDirectory) then
        Misc.CreateDir(WADsDirectory)
    end
    WADs = listFilesRecursively(WADsDirectory)
    for i = #WADs, 1, -1 do
        if not isWADValid(WADsDirectory.."/"..WADs[i]) then
            table.remove(WADs, i)
        end
    end
    return WADs
end

local function getWAD(name)
    return WADsDirectory.."/"..name
end

return {
    getWADs = getWADs,
    getWAD = getWAD
}