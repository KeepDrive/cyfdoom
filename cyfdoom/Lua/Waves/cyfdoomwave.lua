require "cyf3d"
require "wad"
require "math"

local sqrt = math.sqrt
local min = math.min
local max = math.max
local ceil = math.ceil
local sin = math.sin
local cos = math.cos
local rad = math.rad

wadName = "DOOM"
mapName = "E1M1"

worldScale = 1/90
speed = 0.2
animSpeed = 8/30--Animation speed in the source code of Doom is defined as 8.
--8 of what i am not totally sure, but it's probably frames

local wadRead = coroutine.create(wad.read)

local loadScreen = CreateSprite("bg", "Top")
loadScreen.Scale(2, 2)
local textAttrs = "[instant][color:ffffff][font:uidialog]"
local loadText = CreateText(textAttrs .. "Test", {30, 40}, 580, "Top")
loadText.HideBubble()
loadText.progressmode = "none"
NewAudio.Stop("src")

function CreateStuff()
    walls = {}
    if mapName:match("E%dM%d") then
        bg = CreateSprite("WADs/" .. wadName .. "/Textures/SKY" .. mapName:sub(2,2), "Top")
    else
        -- I have no clue if this is correct or not to how DOOM2-style maps handle backgrounds
        -- TODO: look up how DOOM2 works
        bg = CreateSprite("WADs/" .. wadName .. "/Textures/SKY" .. mapName:sub(4,2), "Top")
    end
    sc = 640 / bg.width
    bg.Scale(sc, sc)
    bg.SetPivot(0, 1)
    bg.MoveTo(0, 490)--Idk why but in the original Doom the background is like 9 or 10 pixels up, I should look into that
    --TODO: look up how DOOM works
    if not pcall(bg.shader.Set, "cyfdoom", "DoomBG") then
        DEBUG("Background shader failed to load, and if it failed - I wouldn't have much hope for the rest of them, sorry")
    end
    bg.shader.SetWrapMode("repeat")

    map = require("WADs/" .. wadName .. "/Maps/" .. mapName)

    LINEDEFS = map["LINEDEFS"]
    SIDEDEFS = map["SIDEDEFS"]
    SECTORS = map["SECTORS"]
    VERTEXES = map["VERTEXES"]
    TRIANGLES = map["TRIANGLES"]
    THINGS = map["THINGS"]

    local spritespath = "WADs/" .. wadName .. "/Sprites/"

    for i = 1, #THINGS do
        local thing = THINGS[i]
        if thing[5] == 1 then
            cyf3dcamerax = thing[1] * worldScale
            cyf3dcameray = (thing[2] + 56) * worldScale
            cyf3dcameraz = thing[3] * worldScale
            cyf3dcamerayrot = thing[4] - 90
        end
        if thingSpriteSequence[thing[5]] != nil then
            spriteSequence = thingSpriteSequence[thing[5]]
            anim = {}
            local thingSprite = 0
            if spriteSequence[2] != '*' then
                for i = 1, #spriteSequence[2] do
                    anim[#anim + 1] = spritespath .. spriteSequence[1] .. spriteSequence[2]:sub(i, i) .. '0'
                end
                thingSprite = cyf3dCreateObject(anim[1], "DoomSprite")
            else
                thingSprite = cyf3dCreateObject(spritespath .. spriteSequence[1] .. "A1", "DoomSprite")
            end
            thingSprite.shader.setVector("pos", {thing[1] * worldScale, (thing[2] + thingSprite.height * 0.5) * worldScale, thing[3] * worldScale, 0})
            thingSprite.shader.setFloat("scale", worldScale)
            if #anim > 1 then
                thingSprite.SetAnimation(anim, animSpeed)
            end
        end
    end
    
    THINGS = nil

    map = nil

    local texturesPath = "WADs/" .. wadName .. "/Textures/"
    local flatsPath = "WADs/" .. wadName .. "/Flats/"

    local cachedAnims = {}

    local getAnim = function(definedAnims, path, firstFrame)
        if cachedAnims[path .. firstFrame] == nil then
            local anim = {path .. firstFrame}
            local curFrame = definedAnims[firstFrame]
            while curFrame != firstFrame do
                anim[#anim + 1] = path .. curFrame
                curFrame = definedAnims[curFrame]
            end
            cachedAnims[path .. firstFrame] = anim
            return anim
        else
            return cachedAnims[path .. firstFrame]
        end
    end
    local length = 0
    local x1 = 0
    local x2 = 0
    local z1 = 0
    local z2 = 0
    local createWall = function(sidedef, textureid, y1, y2, backside, transparent)
        local obj = 0
        if transparent then
            walls[#walls + 1] = cyf3dCreateObject("empty", "DoomTransparentWall")
            obj = walls[#walls]
        else
            walls[#walls + 1] = cyf3dCreateObject(texturesPath .. sidedef[textureid], "DoomWall")
            if definedTextureAnims[sidedef[textureid]] != nil then
                walls[#walls].SetAnimation(getAnim(definedTextureAnims, texturesPath, sidedef[textureid]), animSpeed)
            end
        end
        local obj = walls[#walls]
        local uvoffx = sidedef[1]/obj.width
        local uvoffy = -sidedef[2]/obj.height
        local height = ((y1-y2) / worldScale) / obj.height + uvoffy
        local width = length / obj.width + uvoffx
        local SetVector = obj.shader.SetVector
        if backside then
            SetVector("pos1", {x2, y1, z2, 1})
            SetVector("pos2", {x1, y1, z1, 1})
            SetVector("pos3", {x2, y2, z2, 1})
            SetVector("pos4", {x1, y2, z1, 1})
        else
            SetVector("pos1", {x1, y1, z1, 1})
            SetVector("pos2", {x2, y1, z2, 1})
            SetVector("pos3", {x1, y2, z1, 1})
            SetVector("pos4", {x2, y2, z2, 1})
        end
        SetVector("uvpos12", {uvoffx, height, width, height})
        SetVector("uvpos34", {uvoffx, uvoffy, width, uvoffy})
    end
    for i = 1, #LINEDEFS do
        local linedef = LINEDEFS[i]
        local vert1 = VERTEXES[linedef[1] + 1]
        local vert2 = VERTEXES[linedef[2] + 1]
        x1 = vert1[1] * worldScale
        z1 = vert1[2] * worldScale
        x2 = vert2[1] * worldScale
        z2 = vert2[2] * worldScale
        local xdiff = x2 - x1
        local zdiff = z2 - z1
        length = sqrt((xdiff * xdiff) + (zdiff * zdiff)) / worldScale
        if linedef[7] == 65535 and linedef[6] != 65535 then
            local sidedef = SIDEDEFS[linedef[6] + 1]
            local sector = SECTORS[sidedef[6] + 1]
            local y1 = sector[1] * worldScale
            local y2 = sector[2] * worldScale
            createWall(sidedef, 5, y1, y2, false, false)
        elseif linedef[6] == 65535 and linedef[7] != 65535 then
            local sidedef = SIDEDEFS[linedef[7] + 1]
            local sector = SECTORS[sidedef[6] + 1]
            local y1 = sector[1] * worldScale
            local y2 = sector[2] * worldScale
            createWall(sidedef, 5, y1, y2, true, false)
        else
            local sidedef1 = SIDEDEFS[linedef[6] + 1]
            local sidedef2 = SIDEDEFS[linedef[7] + 1]
            local sector1 = SECTORS[sidedef1[6] + 1]
            local sector2 = SECTORS[sidedef2[6] + 1]
            local floorMatch = false
            if sector1[1] == sector2[1] then
                floorMatch = true
            else
                local y1 = min(sector1[1], sector2[1]) * worldScale
                local y2 = (sector1[1] + sector2[1]) * worldScale - y1
                if sidedef1[4] != '-' then
                    createWall(sidedef1, 4, y1, y2, false, false)
                else
                    createWall(sidedef2, 4, y1, y2, true, false)
                end
            end
            if sector1[2] < sector2[2] then
                local y1 = sector1[2] * worldScale
                local y2 = sector2[2] * worldScale
                if sector1[4] == "F_SKY1" and sector2[4] == "F_SKY1" then
                    createWall(sidedef2, 3, y1, y2, true, true)
                elseif sidedef2[3] != '-' then
                    createWall(sidedef2, 3, y1, y2, true, false)
                end
            elseif sector1[2] > sector2[2] then
                local y1 = sector2[2] * worldScale
                local y2 = sector1[2] * worldScale
                if sector1[4] == "F_SKY1" and sector2[4] == "F_SKY1" then
                    createWall(sidedef1, 3, y1, y2, false, true)
                elseif sidedef1[3] != '-' then
                    createWall(sidedef1, 3, y1, y2, false, false)
                end
            else
                if floorMatch then
                    local y1 = sector1[1] * worldScale
                    local y2 = sector1[2] * worldScale
                    if sidedef1[5] != '-' then
                        createWall(sidedef1, 5, y1, y2, false, false)
                    end
                    if sidedef2[5] != '-' then
                        createWall(sidedef2, 5, y1, y2, true, false)
                    end
                end
            end
        end
    end

    LINEDEFS = nil
    SIDEDEFS = nil

    uvCoords = {}
    vertCoords = {}
    vertPairs = {}
    for i = 1, #VERTEXES do
        uvCoords[#uvCoords + 1] = {VERTEXES[i][1] * worldScale, VERTEXES[i][2] * worldScale}
        vertPairs[#vertPairs + 1] = {VERTEXES[i][1], VERTEXES[i][2]}
        vertCoords[#vertCoords + 1] = {vertPairs[#vertPairs][1] * worldScale, 0, vertPairs[#vertPairs][2] * worldScale}
    end

    VERTEXES = nil

    for i = 1, #TRIANGLES do
        if #TRIANGLES[i] != 0 then
            local floorHeight = SECTORS[i][1] * worldScale
            local ceilHeight = SECTORS[i][2] * worldScale
            local ceilExists = SECTORS[i][4] != "F_SKY1"
            local animFloor = {}
            local animCeil = {}
            if definedFlatAnims[SECTORS[i][3]] ~= nil then
                animFloor = getAnim(definedFlatAnims, flatsPath, SECTORS[i][3])
            end
            if ceilExists and definedFlatAnims[SECTORS[i][4]] != nil then
                animCeil = getAnim(definedFlatAnims, flatsPath, SECTORS[i][4])
            end
            local floorCoords = {}
            for j = 0, ceil(#TRIANGLES[i] / 33) - 1 do
                local floor = cyf3dCreateObject("WADs/" .. wadName .. "/Flats/" .. SECTORS[i][3], "DoomFloor")
                if #animFloor != 0 then
                    floor.SetAnimation(animFloor, animSpeed)
                end
                local ceiling
                if ceilExists then
                    ceiling = cyf3dCreateObject("WADs/" .. wadName .. "/Flats/" .. SECTORS[i][4], "DoomCeiling")
                    if #animCeil != 0 then
                        ceiling.SetAnimation(animCeil, animSpeed)
                    end
                else
                    ceiling = cyf3dCreateObject("empty", "DoomTransparentCeiling")
                end
                local joffset = j * 33
                for k = 1, min(#TRIANGLES[i] - joffset, 33) do
                    local kthrice = (k - 1) * 3
                    local triid = joffset + k
                    local vert1 = vertCoords[TRIANGLES[i][triid][1]]
                    local vert2 = vertCoords[TRIANGLES[i][triid][2]]
                    local vert3 = vertCoords[TRIANGLES[i][triid][3]]
                    floor.shader.SetVector("vert" .. tostring(kthrice + 1), {vert1[1], floorHeight, vert1[3], 1})
                    floor.shader.SetVector("vert" .. tostring(kthrice + 2), {vert2[1], floorHeight, vert2[3], 1})
                    floor.shader.SetVector("vert" .. tostring(kthrice + 3), {vert3[1], floorHeight, vert3[3], 1})
                    ceiling.shader.SetVector("vert" .. tostring(kthrice + 1), {vert1[1], ceilHeight, vert1[3], 1})
                    ceiling.shader.SetVector("vert" .. tostring(kthrice + 2), {vert2[1], ceilHeight, vert2[3], 1})
                    ceiling.shader.SetVector("vert" .. tostring(kthrice + 3), {vert3[1], ceilHeight, vert3[3], 1})
                end
            end
        end
    end

    SECTORS = nil
    TRIANGLES = nil

    wad = nil
end

local loading = true

function Update()
    if loading then
        local status, returnval = coroutine.resume(wadRead, wadName)
        loadText.SetText(textAttrs .. returnval)
        loading = (returnval != "Finished loading")
        if not loading then
            CreateStuff()
            loadScreen.Remove()
            loadText.Remove()
        end
    else
        spcosYaw = cos(rad(cyf3dcamerayrot)) * speed
        spsinYaw = sin(rad(cyf3dcamerayrot)) * speed
        spsinPitch = sin(rad(cyf3dcameraxrot)) * speed
        cosPitch = cos(rad(cyf3dcameraxrot))
        if Input.GetKey("D") >= 1 then
            cyf3dcamerax = cyf3dcamerax + spcosYaw
            cyf3dcameraz = cyf3dcameraz - spsinYaw
        end
        if Input.GetKey("A") >= 1 then
            cyf3dcamerax = cyf3dcamerax - spcosYaw
            cyf3dcameraz = cyf3dcameraz + spsinYaw
        end
        if Input.GetKey("W") >= 1 then
            cyf3dcamerax = cyf3dcamerax + spsinYaw * cosPitch
            cyf3dcameray = cyf3dcameray - spsinPitch
            cyf3dcameraz = cyf3dcameraz + spcosYaw*cosPitch
        end
        if Input.GetKey("S") >= 1 then
            cyf3dcamerax = cyf3dcamerax - spsinYaw * cosPitch
            cyf3dcameray = cyf3dcameray + spsinPitch
            cyf3dcameraz = cyf3dcameraz - spcosYaw * cosPitch
        end
        if Input.GetKey("Q") >= 1 then
            cyf3dcameray = cyf3dcameray - speed
        end
        if Input.GetKey("E") >= 1 then
            cyf3dcameray = cyf3dcameray + speed
        end
        if Input.GetKey("UpArrow") >= 1 then
            cyf3dcameraxrot = max(cyf3dcameraxrot - 2, -90)
        end
        if Input.GetKey("DownArrow") >= 1 then
            cyf3dcameraxrot = min(cyf3dcameraxrot + 2, 90)
        end
        if Input.GetKey("LeftArrow") >= 1 then
            cyf3dcamerayrot = (cyf3dcamerayrot - 2) % 360
        end
        if Input.GetKey("RightArrow") >= 1 then
            cyf3dcamerayrot = (cyf3dcamerayrot + 2) %360
        end
        bg.shader.setFloat("xoff", cyf3dcamerayrot / 360)
        cyf3dUpdateObjects()
    end
end
