local png = require "png"
local utils = require "utils"

local isPointOnLineSegment = utils.isPointOnLineSegment
local sortBySecondValue = utils.sortBySecondValue
local isPointBetweenPoints = utils.isPointBetweenPoints
local orientation = utils.orientation
local doLineSegmentsIntersect = utils.doLineSegmentsIntersect
local arePointsCollinear = utils.arePointsCollinear

local min = math.min
local huge = math.huge

local yield = coroutine.yield

local char = string.char

local concat = table.concat

local bxor = bit32.bxor
local band = bit32.band
local bnot = bit32.bnot
local rshift = bit32.rshift

local FileExists = Misc.FileExists
local OpenFile = Misc.OpenFile
local DirExists = Misc.DirExists
local CreateDir = Misc.CreateDir

definedTextureAnims = {
    BLODGR1 = "BLODGR4",
    SLADRIP1 = "SLADRIP3",
    BLODRIP1 = "BLODRIP4",
    FIREWALA = "FIREWALL",
    GSTFONT1 = "GSTFONT3",
    FIRELAV3 = "FIRELAVA",
    FIREMAG1 = "FIREMAG3",
    FIREBLU1 = "FIREBLU2",
    ROCKRED1 = "ROCKRED3",
    BFALL1 = "BFALL4",
    SFALL1 = "SFALL4",
    WFALL1 = "WFALL4",
    DBRAIN1 = "DBRAIN4"
}

definedFlatAnims = {
    NUKAGE1 = "NUKAGE3",
    FWATER1 = "FWATER4",
    SWATER1 = "SWATER4",
    LAVA1 = "LAVA4",
    BLOOD1 = "BLOOD3",
    RROCK05 = "RROCK08",
    SLIME01 = "SLIME04",
    SLIME05 = "SLIME08",
    SLIME09 = "SLIME12"
}


-- Source:https://web.archive.org/web/20100906191901/http://the-stable.lancs.ac.uk/~esasb1/doom/uds/things.html#sprites
thingSpriteSequence = {
    [1] = {"PLAY", '*'},
    [2] = {"PLAY", '*'},
    [3] = {"PLAY", '*'},
    [4] = {"PLAY", '*'},
    [3004] = {"POSS", '*'},
    [84] = {"SSWV", '*'},
    [9] = {"SPOS", '*'},
    [65] = {"CPOS", '*'},
    [3001] = {"TROO", '*'},
    [3002] = {"SARG", '*'},
    [58] = {"SARG", '*'},
    [3006] = {"SKUL", '*'},
    [3005] = {"HEAD", '*'},
    [69] = {"BOS2", '*'},
    [3003] = {"BOSS", '*'},
    [68] = {"BSPI", '*'},
    [71] = {"PAIN", '*'},
    [66] = {"SKEL", '*'},
    [67] = {"FATT", '*'},
    [64] = {"VILE", '*'},
    [7] = {"SPID", '*'},
    [16] = {"CYBR", '*'},
    [88] = {"BBRN", '*'},
    [2005] = {"CSAW", 'A'},
    [2001] = {"SHOT", 'A'},
    [82] = {"SGN2", 'A'},
    [2002] = {"MGUN", 'A'},
    [2003] = {"LAUN", 'A'},
    [2004] = {"PLAS", 'A'},
    [2006] = {"BFUG", 'A'},
    [2007] = {"CLIP", 'A'},
    [2008] = {"SHEL", 'A'},
    [2010] = {"ROCK", 'A'},
    [2047] = {"CELL", 'A'},
    [2048] = {"AMMO", 'A'},
    [2049] = {"SBOX", 'A'},
    [2046] = {"BROK", 'A'},
    [17] = {"CELP", 'A'},
    [8] = {"BPAK", 'A'},
    [2011] = {"STIM", 'A'},
    [2012] = {"MEDI", 'A'},
    [2014] = {"BON1", "ABCDCB"},
    [2015] = {"BON2", "ABCDCB"},
    [2018] = {"ARM1", "AB"},
    [2019] = {"ARM2", "AB"},
    [83] = {"MEGA", "ABCD"},
    [2013] = {"SOUL", "ABCDCB"},
    [2022] = {"PINV", "ABCD"},
    [2023] = {"PSTR", 'A'},
    [2024] = {"PINS", "ABCD"},
    [2025] = {"SUIT", 'A'},
    [2026] = {"PMAP", "ABCDCB"},
    [2045] = {"PVIS", "AB"},
    [5] = {"BKEY", "AB"},
    [13] = {"RKEY", "AB"},
    [6] = {"YKEY", "AB"},
    [40] = {"BSKU", "AB"},
    [38] = {"RSKU", "AB"},
    [39] = {"YSKU", "AB"},
    [2035] = {"BAR1", "AB"},
    [70] = {"FCAN", "ABC"},
    [34] = {"CAND", "A"},
    [35] = {"CBRA", "A"},
    [48] = {"ELEC", "A"},
    [30] = {"COL1", "A"},
    [32] = {"COL3", "A"},
    [31] = {"COL2", "A"},
    [24] = {"COL5", "AB"},
    [33] = {"COL4", "A"},
    [37] = {"COL6", "A"},
    [47] = {"SMIT", "A"},
    [43] = {"TRE1", "A"},
    [54] = {"TRE2", "A"},
    [44] = {"TBLU", "ABCD"},
    [45] = {"TGRE", "ABCD"},
    [46] = {"TRED", "ABCD"},
    [55] = {"SMBT", "ABCD"},
    [56] = {"SMGT", "ABCD"},
    [57] = {"SMRT", "ABCD"},
    [2028] = {"COLU", "A"},
    [85] = {"TLMP", "ABCD"},
    [86] = {"TLP2", "ABCD"},
    [41] = {"CEYE", "ABCD"},
    [42] = {"FSKU", "ABC"},
    [25] = {"POL1", "A"},
    [26] = {"POL6", "AB"},
    [27] = {"POL4", "A"},
    [28] = {"POL2", "A"},
    [29] = {"POL3", "AB"},
    [50] = {"GOR2", "A"},
    [49] = {"GOR1", "ABCD"},
    [52] = {"GOR4", "A"},
    [51] = {"GOR3", "A"},
    [53] = {"GOR5", "A"},
    [73] = {"HDB1", "A"},
    [74] = {"HDB2", "A"},
    [75] = {"HDB3", "A"},
    [76] = {"HDB4", "A"},
    [77] = {"HDB5", "A"},
    [78] = {"HDB6", "A"},
    [72] = {"KEEN", "*"},
    [15] = {"PLAY", "N"},
    [18] = {"POSS", "L"},
    [19] = {"SPOS", "L"},
    [20] = {"TROO", "M"},
    [21] = {"SARG", "N"},
    [22] = {"HEAD", "L"},
    [23] = {"SKUL", "K"},
    [10] = {"PLAY", "W"},
    [12] = {"PLAY", "W"},
    [24] = {"POL5", "A"},
    [79] = {"POB1", "A"},
    [80] = {"POB2", "A"},
    [81] = {"BRS1", "A"},
    [63] = {"GOR1", "ABCD"},
    [59] = {"GOR2", "A"},
    [61] = {"GOR3", "A"},
    [60] = {"GOR4", "A"},
    [62] = {"GOR5", "A"}
}

wad = {}
-- Most info about lumps and what they do from doomwiki.org and "The Unofficial Doom Specs"

function wad.read(fileName)
    if not FileExists(fileName .. ".WAD") then return end
    yield("WAD found")
    
    wad.neededDirs(fileName) -- Check to see if all the needed folders are in place
    yield("Directories in place")
    
    wad.wadFile = OpenFile(fileName..".WAD","r").ReadBytes()
    local identification = wad.readString(1, 4) -- "IWAD" or "PWAD", not actually used anywhere
    
    -- From what I can see DOOM uses a lot of signed values which really could've just been unsigned and worked fine
    -- Like here for example, so I took the liberty to make them unsigned in hopes of potentially improving compatibility
    -- After all some source ports already do that anyway
    local numlumps = wad.readUnsignedInt(5)
    local infotableofs = wad.readUnsignedInt(9) -- Dictionary pointer
    local PLAYPAL = {}
    local PNAMES = {}
    local TEXTURE = {{}, {}}
    local unidentifiedlumps = {}
    for i = 1, #wad.wadFile - infotableofs, 16 do -- Lumps are 16 bytes in size
        local lump = wad.readLump(infotableofs + i)
        
        if lump[3] == "PLAYPAL" then
            
            yield("Reading palette data")
            PLAYPAL = wad.readPlayPal(lump[1])
        
        elseif lump[3] == "TEXTURE1" then
            
            yield("Reading texture1 data")
            TEXTURE[1] = wad.readTexture(lump[1] + 1)
        
        elseif lump[3] == "TEXTURE2" then
            
            yield("Reading texture2 data")
            TEXTURE[2] = wad.readTexture(lump[1] + 1)
        
        elseif lump[3] == "PNAMES" then

            yield("Reading patch names")
            PNAMES = wad.readPNames(lump[1]+1)
        
        elseif (lump[3] == "P_START" or 
                lump[3] == "P1_START" or 
                lump[3] == "P2_START" or 
                lump[3] == "P1_END" or 
                lump[3] == "P2_END" or 
                lump[3] == "P_END" or 
                lump[3] == "F_START" or 
                lump[3] == "F_END"
                ) then
            
            yield("lump " .. lump[3] .. " is unused, skipping")
            -- These quite literally don't do anything
            -- They could be used to more easily identify patches
            -- But they probably shouldn't
        elseif lump[3] == "F1_START" or lump[3] == "F2_START" then
            
            local animLast = '-'
            local animEnd='-'
            while true do
                i = i + 16
                lump = wad.readLump(infotableofs + i)
                
                if lump[3] == "F1_END" or lump[3] == "F2_END" then
                    break
                end
                
                if animEnd != lump[3] and definedFlatAnims[lump[3]] != nil then
                    animEnd = definedFlatAnims[lump[3]]
                    definedFlatAnims[animEnd] = lump[3]
                end
                
                if animLast != '-' then
                    definedFlatAnims[animLast] = lump[3]
                end
                if animEnd != '-' then
                    animLast = lump[3]
                end
                if animEnd == lump[3] then
                    animLast = '-'
                    animEnd = '-'
                end
                
                if FileExists("Sprites/WADs/" .. fileName .. "/Flats/" .. lump[3] .. ".png") then
                    yield("Flat " .. lump[3] .. " exists, skipping")
                else
                    yield("Extracting flat " .. lump[3])
                    wad.readFlat(lump[1] + 1, PLAYPAL, lump[3], fileName)
                end
            end
            
        elseif lump[3]=="S_START" then

            while true do
                i = i + 16
                lump = wad.readLump(infotableofs + i)
                if lump[3] == "S_END" then
                    break
                end
                local spritePath = "Sprites/WADs/" .. fileName .. "/Sprites/" .. lump[3] .. ".png"
                local luaPath = "Lua/Libraries/WADs/" .. fileName .. "/Sprites/" .. lump[3] .. ".lua"
                if FileExists(spritePath) and FileExists(luaPath) then
                    yield("Sprite " .. lump[3] .. " exists, skipping")
                else
                    yield("Extracting sprite " .. lump[3])
                    wad.readAndWritePicture(lump[1] + 1, lump[2], spritePath, luaPath, PLAYPAL)
                end
            end

        elseif (lump[3]:match("E%dM%d") and #lump[3] == 4) or (lump[3]:match("MAP%d%d") and #lump[3] == 5) then

            yield(lump[3] .. ": Reading map data")
            local maptitle = lump[3]
            if FileExists("Lua/Libraries/WADs/" .. fileName .. "/Maps/" .. maptitle .. ".lua") then
                yield(lump[3] .. " already exists, skipping")
            else
                local map = {}
                while true do
                    i = i + 16
                    lump = wad.readLump(infotableofs + i)
                    yield(maptitle .. ": Reading " .. lump[3])
                    if lump[3] == "VERTEXES" then
                        
                        map["VERTEXES"] = {}
                        local VERTEXES = map["VERTEXES"]
                        for j = 1, lump[2], 4 do
                            VERTEXES[#VERTEXES + 1] = wad.readVertex(lump[1] + j)
                        end

                    elseif lump[3] == "LINEDEFS" then
                        
                        map["LINEDEFS"] = {}
                        local LINEDEFS = map["LINEDEFS"]
                        for j = 1, lump[2], 14 do
                            LINEDEFS[#LINEDEFS + 1] = wad.readLinedef(lump[1] + j)
                        end

                    elseif lump[3] == "SIDEDEFS" then
                        
                        map["SIDEDEFS"] = {}
                        local SIDEDEFS = map["SIDEDEFS"]
                        for j = 1, lump[2], 30 do
                            SIDEDEFS[#SIDEDEFS + 1] = wad.readSidedef(lump[1] + j)
                        end

                    elseif lump[3] == "SECTORS" then

                        map["SECTORS"] = {}
                        local SECTORS = map["SECTORS"]
                        for j = 1, lump[2], 26 do
                            SECTORS[#SECTORS + 1] = wad.readSector(lump[1] + j)
                        end

                    elseif lump[3] == "THINGS" then

                        map["THINGS"] = {}
                        local THINGS = map["THINGS"]
                        for j = 1, lump[2], 10 do
                            THINGS[#THINGS + 1] = wad.readThing(lump[1] + j)
                        end

                    elseif lump[3] == "BLOCKMAP" then

                        break -- BLOCKMAP is the final map related lump in DOOM, though Hexen and Heretic seem to have another one right after
                    
                    end
                end

                local sectorlines = {}
                local sectorboxes = {}
                for i = 1, #map["SECTORS"] do
                    sectorlines[i]={}
                    sectorboxes[i]={}
                end

                local edgeconstraints={}
                map["WALLSTRIS"]={}

                for j = 1, #map["LINEDEFS"] do
                    local linedef = map["LINEDEFS"][j]
                    local line = {linedef[1] + 1, linedef[2] + 1}
                    local p1 = map["VERTEXES"][line[1]]
                    local p3 = map["VERTEXES"][line[2]]
                    
                    local pointsonway = {{line[1], 0}}
                    for k = 1, #map["VERTEXES"] do
                        if k != line[1] and k != line[2] then 
                            local p2 = map["VERTEXES"][k]
                            if isPointOnLineSegment(p2, {p1, p3}) then
                                local xdiff = p1[1] - p2[1]
                                local ydiff = p1[2] - p2[2]
                                pointsonway[#pointsonway + 1] = {k, (xdiff * xdiff) + (ydiff * ydiff)}
                            end
                        end
                    end
                    table.sort(pointsonway, sortBySecondValue)
                    local xdiff = p1[1] - p3[1]
                    local ydiff = p1[2] - p3[2]
                    pointsonway[#pointsonway + 1] = {line[2], (xdiff * xdiff) + (ydiff * ydiff)}
                    for k = 2, #pointsonway do
                        if pointsonway[k - 1][2] != pointsonway[k][2] then
                            if k < #pointsonway and pointsonway[k + 1][2] == pointsonway[k][2] then
                                pointsonway[k][1] = min(pointsonway[k + 1][1], pointsonway[k][1])
                                pointsonway[k + 1][1] = pointsonway[k][1]
                            end
                            line = {pointsonway[k - 1][1], pointsonway[k][1]}
                            edgeconstraints[#edgeconstraints + 1] = line
                            if linedef[6] != 65535 then
                                local sector = sectorlines[map["SIDEDEFS"][linedef[6] + 1][6] + 1]
                                sector[#sector + 1] = {line[1], line[2]}
                            end
                            if linedef[7] != 65535 then
                                local sector = sectorlines[map["SIDEDEFS"][linedef[7] + 1][6] + 1]
                                sector[#sector + 1]={line[1], line[2]}
                            end
                        end
                    end
                end

                map["TRIANGLES"] = {}
                local triangulate = require "triangulation"
                for j = 1, #sectorlines do
                    local sectortris = {}
                    local sectorpoints = {}
                    local constraints = {}
                    local xmax = -huge
                    local xmin = huge
                    local ymax = -huge
                    local ymin = huge
                    for k = 1, #sectorlines[j] do
                        local p1 = sectorlines[j][k][1]
                        local p2 = sectorlines[j][k][2]
                        local p1found = false
                        local p2found = false
                        for l = 1, #sectorpoints do
                            if not p1found then
                                p1found = sectorpoints[l] == p1
                                if p1found then
                                    p1 = l
                                end
                            end
                            if not p2found then
                                p2found = sectorpoints[l] == p2
                                if p2found then
                                    p2 = l
                                end
                            end
                            if p1found and p2found then
                                break
                            end
                        end
                        if not p1found then
                            sectorpoints[#sectorpoints + 1] = p1
                            local vert = map["VERTEXES"][p1]
                            if vert[1] > xmax then
                                xmax = vert[1]
                            end
                            if vert[1] < xmin then
                                xmin = vert[1]
                            end
                            if vert[2] > ymax then
                                ymax = vert[2]
                            end
                            if vert[2] < ymin then
                                ymin = vert[2]
                            end
                            p1 = #sectorpoints
                        end
                        if not p2found then
                            sectorpoints[#sectorpoints + 1] = p2
                            local vert = map["VERTEXES"][p2]
                            if vert[1] > xmax then
                                xmax = vert[1]
                            end
                            if vert[1] < xmin then
                                xmin = vert[1]
                            end
                            if vert[2] > ymax then
                                ymax = vert[2]
                            end
                            if vert[2] < ymin then
                                ymin = vert[2]
                            end
                            p2 = #sectorpoints
                        end
                        constraints[k]={p1,p2}
                    end
                    sectorboxes[j] = {xmin, xmax, ymin, ymax}
                    if #sectorpoints >= 3 then
                        local newsectorpoints = {}
                        for k = 1, #sectorpoints do
                            newsectorpoints[k] = map["VERTEXES"][sectorpoints[k]]
                        end
                        yield(maptitle .. ": Triangulating surfaces")
                        sectortris = triangulate(newsectorpoints, constraints)
                        for k = 1, #sectortris do
                            sectortris[k] = {sectorpoints[sectortris[k][1]], sectorpoints[sectortris[k][2]], sectorpoints[sectortris[k][3]]}
                        end
                        map["TRIANGLES"][j] = sectortris
                    else
                        map["TRIANGLES"][j] = {}
                    end
                end
                yield(maptitle .. ": Preparing things")
                for j = 1, #map["THINGS"] do
                    local thing = map["THINGS"][j]
                    local checksectors = {}
                    local point = {thing[1], thing[3]}
                    for k = 1, #sectorboxes do
                        local bbox = sectorboxes[k]
                        if isPointBetweenPoints(point, {bbox[1], bbox[3]}, {bbox[2], bbox[4]}) then
                            checksectors[#checksectors + 1] = k
                        end
                    end
                    for k = 1, #checksectors - 1 do -- We never need to check the last one since an object should always be inside a sector
                        local sec = checksectors[k]
                        local constraints = sectorlines[sec]
                        local nearinfpoint = {huge, point[2]}
                        local nearinfline = {point, nearinfpoint}
                        local inters = 0
                        local exactintersections = {}
                        for l = 1, #constraints do
                            local constraint = constraints[l]
                            local vert1 = map["VERTEXES"][constraint[1]]
                            local vert2 = map["VERTEXES"][constraint[2]]

                            local exactintersect = false
                            if exactintersections[constraint[1]] != nil then
                                exactintersect = true
                                local orient1 = exactintersections[constraint[1]]
                                local orient2 = orientation(point, vert1, vert2)
                                if orient1 != 0 and orient2 != 0 and orient1 != orient2 then
                                    inters = inters + 1
                                end
                            end
                            if exactintersections[constraint[2]]!=nil then
                                exactintersect = true
                                local orient1 = exactintersections[constraint[2]]
                                local orient2 = orientation(point, vert2, vert1)
                                if orient1 != 0 and orient2 != 0 and orient1 != orient2 then
                                    inters = inters + 1
                                end
                            end
                            if not exactintersect then
                                if doLineSegmentsIntersect({vert1, vert2}, nearinfline) then
                                    if arePointsCollinear(point, vert1, nearinfpoint) then
                                        exactintersections[constraint[1]] = orientation(point, vert1, vert2)
                                        exactintersect = true
                                    end
                                    if arePointsCollinear(point, vert2, nearinfpoint) then
                                        exactintersections[constraint[2]] = orientation(point, vert2, vert1)
                                        exactintersect = true
                                    end
                                    if not exactintersect then
                                        inters = inters + 1
                                    end
                                end
                            end
                        end
                        if inters % 2 == 1 then
                            thing[2] = map["SECTORS"][checksectors[k]][1]
                            break
                        end
                    end
                    if thing[2] == '-' then
                        thing[2] = map["SECTORS"][checksectors[#checksectors]][1]
                    end
                end
                local mapfile = OpenFile("Lua/Libraries/WADs/" .. fileName .. "/Maps/" .. maptitle .. ".lua", "w")
                yield(maptitle .. ": Dumping map data to file")
                mapfile.Write("return " .. wad.tableToString(map), false)
            end
        else
            unidentifiedlumps[lump[3]:upper()] = lump
        end
    end
    for i = 1, #PNAMES[2] do
        PNAMES[2][i] = PNAMES[2][i]:upper()
        if not FileExists("Lua/Libraries/WADs/" .. fileName .. "/Patches/" .. PNAMES[2][i] .. ".lua") then
            yield("Creating texture patch " .. PNAMES[2][i])
            wad.readAndWritePicture(unidentifiedlumps[PNAMES[2][i]][1] + 1, unidentifiedlumps[PNAMES[2][i]][2], "Lua/Libraries/WADs/" .. fileName .. "/Patches/" .. PNAMES[2][i] .. ".lua")
        end
        unidentifiedlumps[PNAMES[2][i]] = nil
    end
    --Go back to creating textures
    --Cyclic Redundancy Check code adapted from:
    --http://www.libpng.org/pub/png/spec/1.2/PNG-CRCAppendix.html
    local crctable={0,1996959894,3993919788,2567524794,124634137,1886057615,3915621685,
    2657392035,249268274,2044508324,3772115230,2547177864,162941995,2125561021,
    3887607047,2428444049,498536548,1789927666,4089016648,2227061214,450548861,
    1843258603,4107580753,2211677639,325883990,1684777152,4251122042,2321926636,
    335633487,1661365465,4195302755,2366115317,997073096,1281953886,3579855332,
    2724688242,1006888145,1258607687,3524101629,2768942443,901097722,1119000684,
    3686517206,2898065728,853044451,1172266101,3705015759,2882616665,651767980,
    1373503546,3369554304,3218104598,565507253,1454621731,3485111705,3099436303,
    671266974,1594198024,3322730930,2970347812,795835527,1483230225,3244367275,
    3060149565,1994146192,31158534,2563907772,4023717930,1907459465,112637215,
    2680153253,3904427059,2013776290,251722036,2517215374,3775830040,2137656763,
    141376813,2439277719,3865271297,1802195444,476864866,2238001368,4066508878,
    1812370925,453092731,2181625025,4111451223,1706088902,314042704,2344532202,
    4240017532,1658658271,366619977,2362670323,4224994405,1303535960,984961486,
    2747007092,3569037538,1256170817,1037604311,2765210733,3554079995,1131014506,
    879679996,2909243462,3663771856,1141124467,855842277,2852801631,3708648649,
    1342533948,654459306,3188396048,3373015174,1466479909,544179635,3110523913,
    3462522015,1591671054,702138776,2966460450,3352799412,1504918807,783551873,
    3082640443,3233442989,3988292384,2596254646,62317068,1957810842,3939845945,
    2647816111,81470997,1943803523,3814918930,2489596804,225274430,2053790376,
    3826175755,2466906013,167816743,2097651377,4027552580,2265490386,503444072,
    1762050814,4150417245,2154129355,426522225,1852507879,4275313526,2312317920,
    282753626,1742555852,4189708143,2394877945,397917763,1622183637,3604390888,
    2714866558,953729732,1340076626,3518719985,2797360999,1068828381,1219638859,
    3624741850,2936675148,906185462,1090812512,3747672003,2825379669,829329135,
    1181335161,3412177804,3160834842,628085408,1382605366,3423369109,3138078467,
    570562233,1426400815,3317316542,2998733608,733239954,1555261956,3268935591,
    3050360625,752459403,1541320221,2607071920,3965973030,1969922972,40735498,
    2617837225,3943577151,1913087877,83908371,2512341634,3803740692,2075208622,
    213261112,2463272603,3855990285,2094854071,198958881,2262029012,4057260610,
    1759359992,534414190,2176718541,4139329115,1873836001,414664567,2282248934,
    4279200368,1711684554,285281116,2405801727,4167216745,1634467795,376229701,
    2685067896,3608007406,1308918612,956543938,2808555105,3495958263,1231636301,
    1047427035,2932959818,3654703836,1088359270,936918000,2847714899,3736837829,
    1202900863,817233897,3183342108,3401237130,1404277552,615818150,3134207493,
    3453421203,1423857449,601450431,3009837614,3294710456,1567103746,711928724,
    3020668471,3272380065,1510334235,755167117}
    for i = 1, 2 do
        for j = 1, #TEXTURE[i][3] do
            local textureData = TEXTURE[i][3][j]
            if FileExists("Sprites/WADs/" .. fileName .. "/Textures/" .. textureData[1] .. ".png") then
                yield("Texture "..textureData[1].." exists, skipping")
            else
                yield("Creating texture " .. textureData[1])
                local texture = {}
                local width = textureData[3]
                local height = textureData[4]
                local patches = textureData[7]
                local patchimgs = {}
                for k = 1, #patches do
                    local patchid = patches[k][3] + 1
                    if patchimgs[patchid] == nil then
                        patchimgs[patchid] = require("WADs/" .. fileName .. "/Patches/" .. PNAMES[2][patchid])
                    end
                end
                local bytes = {137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,0,0,0,0,0,8,6,0,0,0,0,0,0,0,0,0,0,0,73,68,65,84,120,1}
                local wrtsize = width
                for k = 20, 17, -1 do
                    bytes[k] = band(wrtsize, 255)
                    wrtsize = rshift(wrtsize, 8)
                end
                local wrtsize = height
                for k = 24, 21, -1 do
                    bytes[k] = band(wrtsize, 255)
                    wrtsize = rshift(wrtsize, 8)
                end
                local c = 1465799157 --Precalced part of crc for the header name
                for n = 17, 29 do -- Header name skipped because it's precalced
                    c = bxor(
                        crctable[
                            band(
                                bxor(c, bytes[n]),
                                255
                            ) + 1
                        ],
                        rshift(c, 8)
                    )
                end
                c = bxor(c, 4294967295)
                for k = 33, 30, -1 do
                    bytes[k] = band(c, 255)
                    c = rshift(c, 8)
                end
                local length = height * (width * 4 + 6) + 11
                for i = 37, 34, -1 do
                    bytes[i] = band(length, 255)
                    length = rshift(length, 8)
                end
                c = 333807917-- We'll be calculating the crc as we go
                -- Header and compression method and whatever are precalced
                local A = 1
                local B = 0
                for y = 0, height - 1 do
                    local order = {}
                    for k = 1, #patches do
                        local patch = patches[k]
                        local patchy = patch[2]
                        if patchy <= y and y <= patchy + patchimgs[patch[3] + 1][2] - 1 then
                            order[#order + 1] = patch
                        end
                    end
                    bytes[#bytes + 1] = 0
                    -- Any value xor 0 results in the initial value, so we can simplify that for the crc calculation
                    c = bxor(crctable[band(c, 255) + 1], rshift(c, 8))
                    datsize = 1 + width * 4
                    for k = #bytes + 1, #bytes + 2 do
                        bytes[#bytes + 1] = band(datsize, 255)
                        c = bxor(crctable[band(bxor(c, bytes[#bytes]), 255) + 1], rshift(c, 8))
                        datsize = rshift(datsize, 8)
                    end
                    datsize=bnot(1 + width * 4)
                    for k = #bytes + 1, #bytes + 2 do
                        bytes[#bytes + 1] = band(datsize, 255)
                        c=bxor(crctable[band(bxor(c, bytes[#bytes]), 255) + 1], rshift(c, 8))
                        datsize = rshift(datsize, 8)
                    end
                    bytes[#bytes + 1] = 0
                    c = bxor(crctable[band(c, 255) + 1], rshift(c, 8))
                    B = (B + A) % 65521
                    for x = 0, width - 1 do
                        local firstval = #texture + 1
                        texture[firstval] = 0
                        texture[firstval + 1] = 0
                        texture[firstval + 2] = 0
                        texture[firstval + 3] = 0
                        if #order != 0 then
                            for k = #order, 1, -1 do
                                local patch = order[k]
                                local patchx = patch[1]
                                local patchy = patch[2]
                                local patchimg = patchimgs[patch[3] + 1]
                                local patchwidth = patchimg[1]
                                if x > patchx + patchwidth - 1 then
                                    table.remove(order, k)
                                else
                                    local patchheight = patchimg[2]
                                    if x >= patchx then
                                        local colour = patchimg[x - patchx + (y - patchy) * patchwidth + 5] * 3 + 1
                                        if colour!=769 then--colour 256 represents an empty pixel, 256*3+1=769
                                            bytes[#bytes + 1] = PLAYPAL[colour]
                                            c = bxor(crctable[band(bxor(c, bytes[#bytes]), 255) + 1], rshift(c, 8))
                                            A = (A + bytes[#bytes]) % 65521
                                            B = (B + A) % 65521
                                            bytes[#bytes + 1] = PLAYPAL[colour + 1]
                                            c = bxor(crctable[band(bxor(c, bytes[#bytes]), 255) + 1], rshift(c, 8))
                                            A = (A + bytes[#bytes]) % 65521
                                            B = (B + A) % 65521
                                            bytes[#bytes + 1] = PLAYPAL[colour + 2]
                                            c = bxor(crctable[band(bxor(c, bytes[#bytes]), 255) + 1], rshift(c, 8))
                                            A = (A + bytes[#bytes]) % 65521
                                            B = (B + A) % 65521
                                            bytes[#bytes + 1] = 255
                                            -- Any value xor 255 is not(any value), simplified to 255-c
                                            -- (not exactly true, if c is more than 8 bits long that is no longer the case)
                                            -- (but here it is fine because it gets shortened to 8 bits anyway using bitwise and)
                                            c = bxor(crctable[band(255 - c, 255) + 1], rshift(c, 8))
                                            A = (A + 255) % 65521
                                            B = (B + A) % 65521
                                            break
                                        elseif k == 1 then--If it's the last patch checked then it must be empty
                                            bytes[#bytes+1]=0
                                            c=bxor(crctable[band(c, 255) + 1], rshift(c, 8))
                                            A = A % 65521
                                            B = (A * 4 + B) % 65521
                                            bytes[#bytes + 1] = 0
                                            c = bxor(crctable[band(c, 255) + 1], rshift(c, 8))
                                            bytes[#bytes + 1] = 0
                                            c = bxor(crctable[band(c, 255) + 1], rshift(c, 8))
                                            bytes[#bytes + 1] = 0
                                            c = bxor(crctable[band(c, 255) + 1], rshift(c, 8))
                                        end
                                    end
                                end
                            end
                        else
                            bytes[#bytes + 1] = 0
                            c = bxor(crctable[band(c, 255) + 1], rshift(c, 8))
                            A = A % 65521
                            B = (A * 4 + B) % 65521
                            bytes[#bytes + 1] = 0
                            c = bxor(crctable[band(c, 255) + 1], rshift(c, 8))
                            bytes[#bytes + 1] = 0
                            c = bxor(crctable[band(c, 255) + 1], rshift(c, 8))
                            bytes[#bytes + 1] = 0
                            c = bxor(crctable[band(c, 255) + 1], rshift(c, 8))
                        end
                    end
                end
                bytes[#bytes + 1] = 1
                c = bxor(crctable[band(bxor(c, 1), 255) + 1], rshift(c, 8))
                bytes[#bytes + 1] = 0
                c = bxor(crctable[band(c, 255) + 1], rshift(c, 8))
                bytes[#bytes + 1] = 0
                c = bxor(crctable[band(c, 255) + 1], rshift(c, 8))
                bytes[#bytes + 1] = 255
                c = bxor(crctable[band(255 - c, 255) + 1], rshift(c, 8))
                bytes[#bytes + 1] = 255
                c = bxor(crctable[band(255 - c, 255) + 1], rshift(c, 8))
                bytes[#bytes + 1] = 0
                for i = #bytes + 1, #bytes, -1 do
                    bytes[i] = band(B, 255)
                    B = rshift(B, 8)
                end
                c = bxor(crctable[band(bxor(c, bytes[#bytes - 1]), 255) + 1], rshift(c, 8))
                c = bxor(crctable[band(bxor(c, bytes[#bytes]), 255) + 1], rshift(c, 8))
                bytes[#bytes + 1] = 0
                for i = #bytes + 1, #bytes, -1 do
                    bytes[i] = band(A, 255)
                    A = rshift(A, 8)
                end
                c = bxor(crctable[band(bxor(c, bytes[#bytes - 1]), 255) + 1], rshift(c, 8))
                c = bxor(crctable[band(bxor(c, bytes[#bytes]), 255) + 1], rshift(c, 8))
                c = bxor(c, 4294967295)
                bytes[#bytes + 1] = 0
                bytes[#bytes + 1] = 0
                bytes[#bytes + 1] = 0
                for i = #bytes + 1, #bytes - 2, -1 do
                    bytes[i] = band(c, 255)
                    c = rshift(c, 8)
                end
                bytes[#bytes + 1] = 0
                bytes[#bytes + 1] = 0
                bytes[#bytes + 1] = 0
                bytes[#bytes + 1] = 0
                bytes[#bytes + 1] = 73
                bytes[#bytes + 1] = 69
                bytes[#bytes + 1] = 78
                bytes[#bytes + 1] = 68
                bytes[#bytes + 1] = 174
                bytes[#bytes + 1] = 66
                bytes[#bytes + 1] = 96
                bytes[#bytes + 1] = 130
                OpenFile("Sprites/WADs/" .. fileName .. "/Textures/" .. textureData[1] .. ".png", "w").WriteBytes(bytes)
                bytes = nil
            end
        end
    end
    crctable = nil
    wad.wadFile = nil
    return "Finished loading"
end

--Custom datatype readers

function wad.readLump(lumpStart) -- 16 bytes
    local lumpHeaderData = {}
    lumpHeaderData[1] = wad.readUnsignedInt(lumpStart)          -- filepos - pointer to lump data
    lumpHeaderData[2] = wad.readUnsignedInt(lumpStart + 4)      -- size - size of lump data in bytes
    lumpHeaderData[3] = wad.readString(lumpStart + 8, 8)        -- name
    return lumpHeaderData
end
function wad.readLinedef(linedefStart) -- 14 bytes
    local linedefData = {}
    linedefData[1] = wad.readUnsignedShort(linedefStart)        -- Start Vertex
    linedefData[2] = wad.readUnsignedShort(linedefStart + 2)    -- End Vertex
    linedefData[3] = wad.readShort(linedefStart + 4)            -- Flags
    linedefData[4] = wad.readShort(linedefStart + 6)            -- Special Type
    linedefData[5] = wad.readShort(linedefStart + 8)            -- Sector Tag
    linedefData[6] = wad.readUnsignedShort(linedefStart + 10)   -- Front Sidedef
    linedefData[7] = wad.readUnsignedShort(linedefStart + 12)   -- Back Sidedef
    return linedefData
end
function wad.readSidedef(sidedefStart) -- 30 bytes
    local sidedefData = {}
    sidedefData[1] = wad.readShort(sidedefStart)                -- X offset
    sidedefData[2] = wad.readShort(sidedefStart + 2)            -- Y offset
    sidedefData[3] = wad.readString(sidedefStart + 4, 8)        -- Upper texture
    sidedefData[4] = wad.readString(sidedefStart + 12, 8)       -- Lower texture
    sidedefData[5] = wad.readString(sidedefStart + 20, 8)       -- Middle texture
    sidedefData[6] = wad.readUnsignedShort(sidedefStart + 28)   -- Sector
    return sidedefData
end
function wad.readSector(sectorStart) -- 26 bytes
    local sectorData = {}
    sectorData[1] = wad.readShort(sectorStart)                  -- Floor height
    sectorData[2] = wad.readShort(sectorStart + 2)              -- Ceiling height
    sectorData[3] = wad.readString(sectorStart + 4, 8)          -- Floor texture
    sectorData[4] = wad.readString(sectorStart + 12, 8)         -- Ceiling texture
    sectorData[5] = wad.readShort(sectorStart + 20)             -- Light level
    sectorData[6] = wad.readShort(sectorStart + 22)             -- Special Type
    sectorData[7] = wad.readShort(sectorStart + 24)             -- Tag number
    return sectorData
end
function wad.readVertex(vertexStart) -- 4 bytes
    local vertexData = {}
    vertexData[1] = wad.readShort(vertexStart)                  -- X
    vertexData[2] = wad.readShort(vertexStart + 2)              -- Y
    return vertexData
end
function wad.readThing(thingStart) -- 10 bytes
    local thingData = {}
    thingData[1] = wad.readShort(thingStart)                    -- X
    thingData[2] = '-'                                          -- Y
    thingData[3] = wad.readShort(thingStart + 2)                -- Z(Y)
    thingData[4] = wad.readShort(thingStart + 4)                -- Angle
    thingData[5] = wad.readUnsignedShort(thingStart + 6)        -- Type
    thingData[6] = wad.readUnsignedShort(thingStart + 8)        -- Flags
    return thingData
end
function wad.readTexture(textureStart) -- ? bytes
    local textureData = {}
    textureData[1] = wad.readUnsignedInt(textureStart)          -- numtextures
    textureData[2] = {}
    textureData[3] = {}
    for i = 4, textureData[1] * 4 + 4, 4 do
        textureData[2][#textureData[2] + 1] = wad.readUnsignedInt(textureStart + i)
    end
    local animLast = '-'
    local animEnd = '-'
    for i = 1, textureData[1] do
        local curTexture = {}
        local mapTextureStart = textureStart + textureData[2][i]
        local name = wad.readString(mapTextureStart, 8)         -- name
        curTexture[1] = name
        if animEnd != name and definedTextureAnims[name] != nil then
            animEnd = definedTextureAnims[name]
            definedTextureAnims[animEnd] = name
        end
        if animLast != '-' then
            definedTextureAnims[animLast] = name
        end
        if animEnd != '-' then
            animLast = name
        end
        if animEnd == name then
            animLast = '-'
            animEnd = '-'
        end
        curTexture[2] = wad.readUnsignedInt(mapTextureStart + 8)            --masked, unused????
        curTexture[3] = wad.readUnsignedShort(mapTextureStart + 12)         --width
        curTexture[4] = wad.readUnsignedShort(mapTextureStart + 14)         --height
        curTexture[5] = wad.readUnsignedInt(mapTextureStart + 16)           --columndirectory, unused
        curTexture[6] = wad.readUnsignedShort(mapTextureStart + 20)         --patchcount
        curTexture[7] = {}
        for j = 22, curTexture[6] * 10 + 12, 10 do
            local k = #curTexture[7] + 1
            local curPatch = {}
            curPatch[1] = wad.readShort(mapTextureStart + j)                --originx
            curPatch[2] = wad.readShort(mapTextureStart + j + 2)            --originy
            curPatch[3] = wad.readUnsignedShort(mapTextureStart + j + 4)    --patch
            curPatch[4] = wad.readUnsignedShort(mapTextureStart + j + 6)    --stepdir, unused
            curPatch[5] = wad.readUnsignedShort(mapTextureStart + j + 8)    --colormap, unsused
            curTexture[7][k] = curPatch
        end
        textureData[3][i] = curTexture
    end
    return textureData
end
function wad.readPNames(pnameStart) -- ? bytes
    local pnameData = {}
    pnameData[1] = wad.readUnsignedInt(pnameStart)              --nummappatches
    pnameData[2] = {}
    for i = 4, pnameData[1] * 8 - 4, 8 do
        pnameData[2][#pnameData[2] + 1] = wad.readString(pnameStart + i, 8)
    end
    return pnameData
end
function wad.readAndWritePicture(pictureStart,dataLength,picturePath,metadataPath,playpal) --? bytes
    if playpal == nil then return end
    local pictureData = {}
    pictureData[1] = wad.readUnsignedShort(pictureStart)        --width
    pictureData[2] = wad.readUnsignedShort(pictureStart + 2)    --height
    pictureData[3] = wad.readShort(pictureStart + 4)            --Left offset
    pictureData[4] = wad.readShort(pictureStart + 6)            --Top offset
    pictureData[5] = {} -- Posts
    for i = 1, pictureData[1] do
        local postStart = pictureStart + wad.readUnsignedInt(pictureStart + (i * 4) + 4)
        local nextCol = 0
        if i < pictureData[1] then
            nextCol = pictureStart + wad.readUnsignedInt(pictureStart + (i * 4) + 8)
        else
            nextCol = pictureStart + dataLength
        end
        local curPost = {}
        for j = 1, pictureData[2] do
            curPost[j] = 256
        end
        while postStart < nextCol do
            local topDelta = wad.wadFile[postStart]
            local length = wad.wadFile[postStart + 1]
            if topDelta != 255 then
                for j = 1, min(length, pictureData[2] - topDelta) do
                    local pix = wad.wadFile[postStart + j + 2] -- Skipped padding byte accounted for
                    if pix == 255 then
                        break
                    end
                    curPost[j + topDelta] = pix
                end
            end
            postStart = postStart + length + 4
        end
        pictureData[5][i] = curPost
    end
    local newFile = OpenFile(metadataPath, 'w')
    newFile.Write("return {" .. tostring(pictureData[1]) .. ',' .. tostring(pictureData[2]) .. ',' .. tostring(pictureData[3]) .. ',' .. tostring(pictureData[4]) .. '}',false)
    local img = {}
    for i = 1, pictureData[2] do
        for j = 1, pictureData[1] do
            local pix = pictureData[5][j][i] * 3
            if pix == 768 then
                img[#img + 1] = 0
                img[#img + 1] = 0
                img[#img + 1] = 0
                img[#img + 1] = 0
            else
                img[#img + 1] = playpal[pix + 1]
                img[#img + 1] = playpal[pix + 2]
                img[#img + 1] = playpal[pix + 3]
                img[#img + 1] = 255
            end
        end
    end
    png.CreateNewImage(pictureData[1], pictureData[2], img)
    png.WriteFile(picturePath)
end
function wad.readFlat(flatStart, playpal, flatName, fileName) -- 4096 bytes
    local flatData = {}
    for i = 0, 4095 do
        flatData[#flatData + 1] = playpal[wad.wadFile[flatStart + i] * 3 + 1]
        flatData[#flatData + 1] = playpal[wad.wadFile[flatStart + i] * 3 + 2]
        flatData[#flatData + 1] = playpal[wad.wadFile[flatStart + i] * 3 + 3]
        flatData[#flatData + 1] = 255
    end
    png.CreateNewImage(64, 64, flatData)
    png.WriteFile("Sprites/WADs/" .. fileName .. "/Flats/" .. flatName .. ".png")
end
function wad.readPlayPal(playpalStart)
    local playpalData={}
    for i = 1, 768 do
        playpalData[i] = wad.wadFile[playpalStart + i]
    end
    return playpalData
end

--Datatype readers

function wad.readUnsignedInt(intStart)
    return wad.wadFile[intStart + 3] * 16777216 + wad.wadFile[intStart + 2] * 65536 + wad.wadFile[intStart + 1] * 256 + wad.wadFile[intStart]
end
function wad.readUnsignedShort(shortStart)
    return wad.wadFile[shortStart + 1] * 256 + wad.wadFile[shortStart]
end
function wad.readInt(intStart)
    local res = wad.readUnsignedInt(intStart)
    return res >= 2147483648 and res - 4294967296 or res
end
function wad.readShort(shortStart)
    local res = wad.readUnsignedShort(shortStart)
    return res >= 32768 and res - 65536 or res
end
function wad.readString(strstart, bytes)
    bytes = bytes or 4
    local charTable = {}
    for i = 0, bytes - 1 do
        local numval = wad.wadFile[strstart + i]
        if numval > 0 then
            charTable[#charTable + 1] = char(numval)
        end
    end
    return concat(charTable)
end

--Utils

function wad.neededDirs(fileName)
    local libpath = "Lua/Libraries/WADs/" .. fileName
    local sprpath = "Sprites/WADs/" .. fileName
    local dirs={"Lua/Libraries/WADs",
                libpath,
                libpath .. "/Maps",
                libpath .. "/Patches",
                libpath .. "/Sprites",
                "Sprites/WADs",
                sprpath,
                sprpath .. "/Textures",
                sprpath .. "/Flats",
                sprpath .. "/Sprites"
                }
    for i = 1, #dirs do
        if not DirExists(dirs[i]) then
            CreateDir(dirs[i])
        end
    end
end
function wad.tableToString(intable)
    local str = '{'
    local first = true
    for key,val in pairs(intable) do
        if first then
            firt = false
        else
            str = str .. ','
        end
        
        if type(key) == "string" then
            str = str .. key .. '='
        end
        if type(val) == "table" then
            str = str .. wad.tableToString(val)
        elseif type(val) == "string" then
            str = str .. '"' .. val .. '"'
        else
            str = str .. tostring(val)
        end
    end
    return str .. '}'
end