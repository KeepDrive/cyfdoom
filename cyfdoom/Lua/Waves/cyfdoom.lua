require "cyf3dfordoom"
require "wad"
require "math"

wadname="DOOM"
mapname="E1M1"

worldscale=1/90
speed=0.2
animspeed=8/30--Animation speed in the source code of Doom is defined as 8.
--8 of what i am not totally sure, but it's probably frames

local wadread=coroutine.create(wad.read)

local loadscreen=CreateSprite("bg","Top")
loadscreen.Scale(2,2)
local textattrs="[instant][color:ffffff][font:uidialog]"
local loadtext=CreateText(textattrs.."Test",{30,40},580,"Top")
loadtext.HideBubble()
loadtext.progressmode = "none"
NewAudio.Stop("src")

function CreateStuff()
    walls={}
    if mapname:match("E%dM%d") then
        bg=CreateSprite("WADs/"..wadname.."/Textures/SKY"..mapname:sub(2,2),"Top")
    else
        --I have no clue if this is correct or not to how DOOM2-style maps handle backgrounds
        bg=CreateSprite("WADs/"..wadname.."/Textures/SKY"..mapname:sub(4,2),"Top")
    end
    sc=640/bg.width
    bg.Scale(sc,sc)
    bg.SetPivot(0,1)
    bg.MoveTo(0,490)--idk why but in the original Doom the background is like 9 or 10 pixels up, i should look into that
    if not pcall(bg.shader.Set,"cyfdoom","DoomBG") then
        DEBUG("Background shader failed to load, and if it failed - I wouldn't have much hope for the rest of them, sorry")
    end
    bg.shader.SetWrapMode("repeat")

    map=require("WADs/"..wadname.."/Maps/"..mapname)

    LINEDEFS=map["LINEDEFS"]
    SIDEDEFS=map["SIDEDEFS"]
    SECTORS=map["SECTORS"]
    VERTEXES=map["VERTEXES"]
    TRIANGLES=map["TRIANGLES"]
    WALLSTRIS=map["WALLSTRIS"]
    THINGS=map["THINGS"]

    local spritespath="WADs/"..wadname.."/Sprites/"

    for i=1,#THINGS do
        local thing=THINGS[i]
        if thing[5]==1 then
            cyf3dcamerax=thing[1]*worldscale
            cyf3dcameray=(thing[2]+56)*worldscale
            cyf3dcameraz=thing[3]*worldscale
            cyf3dcamerayrot=thing[4]-90
        end
        if thingspritesequence[thing[5]]!=nil then
            spritesequence=thingspritesequence[thing[5]]
            if spritesequence[2]!='*' then
                anim={}
                for i=1,#spritesequence[2] do
                    anim[#anim+1]=spritespath..spritesequence[1]..spritesequence[2]:sub(i,i)..'0'
                end
                local thingsprite=cyf3dCreate3DSprite(anim[1])
                thingsprite.shader.setVector("pos",{thing[1]*worldscale,(thing[2]+thingsprite.height*0.5)*worldscale,thing[3]*worldscale,0})
                thingsprite.shader.setFloat("scale",worldscale)
                if #anim!=1 then
                    thingsprite.SetAnimation(anim,animspeed)
                end
            else
                local thingsprite=cyf3dCreate3DSprite(spritespath..spritesequence[1].."A1")
                thingsprite.shader.setVector("pos",{thing[1]*worldscale,(thing[2]+thingsprite.height*0.5)*worldscale,thing[3]*worldscale,0})
                thingsprite.shader.setFloat("scale",worldscale)
            end
        end
    end
    
    THINGS=nil

    map=nil

    local texturespath="WADs/"..wadname.."/Textures/"
    local flatspath="WADs/"..wadname.."/Flats/"

    local cachedanims={}

    local getanim=function(definedanims,path,firstframe)
        if cachedanims[path..firstframe]==nil then
            local anim={path..firstframe}
            local curframe=definedanims[firstframe]
            while curframe!=firstframe do
                anim[#anim+1]=path..curframe
                if definedanims[curframe]==nil then
                    error(firstframe)
                end
                curframe=definedanims[curframe]
            end
            cachedanims[path..firstframe]=anim
            return anim
        else
            return cachedanims[path..firstframe]
        end
    end
    for i=1,#LINEDEFS do
        vert1=VERTEXES[LINEDEFS[i][1]+1]
        vert2=VERTEXES[LINEDEFS[i][2]+1]
        local x1=vert1[1]*worldscale
        local z1=vert1[2]*worldscale
        local x2=vert2[1]*worldscale
        local z2=vert2[2]*worldscale
        local length=math.sqrt((x2-x1)^2+(z2-z1)^2)/worldscale
        --Most of the following code accounts for back-face culling
        --Strangely enough though it is not always consistent, so I turned culling off for now until i understand what's going on
        if LINEDEFS[i][7]==65535 and LINEDEFS[i][6]!=65535 then
            local sidedef=SIDEDEFS[LINEDEFS[i][6]+1]
            local sector=SECTORS[sidedef[6]+1]
            walls[#walls+1]=cyf3dCreateQuad(texturespath..sidedef[5])
            if definedtextureanims[sidedef[5]]!=nil then
                walls[#walls].SetAnimation(getanim(definedtextureanims,texturespath,sidedef[5]),animspeed)
            end
            local obj=walls[#walls]
            local y1=sector[1]*worldscale
            local y2=sector[2]*worldscale
            local height=(y2-y1)/worldscale
            local uvoffx=sidedef[1]/obj.width
            local uvoffy=-sidedef[2]/obj.height
            local width=length/obj.width+uvoffx
            height=-height/obj.height+uvoffy
            obj.shader.SetVector("pos1",{x1,y1,z1,1})
            obj.shader.SetVector("pos2",{x2,y1,z2,1})
            obj.shader.SetVector("pos3",{x1,y2,z1,1})
            obj.shader.SetVector("pos4",{x2,y2,z2,1})
            obj.shader.SetVector("uvpos12",{uvoffx,height,width,height})
            obj.shader.SetVector("uvpos34",{uvoffx,uvoffy,width,uvoffy})
        elseif LINEDEFS[i][6]==65535 and LINEDEFS[i][7]!=65535 then
            local sidedef=SIDEDEFS[LINEDEFS[i][7]+1]
            local sector=SECTORS[sidedef[6]+1]
            walls[#walls+1]=cyf3dCreateQuad(texturespath..sidedef[5])
            if definedtextureanims[sidedef[5]]!=nil then
                walls[#walls].SetAnimation(getanim(definedtextureanims,texturespath,sidedef[5]),animspeed)
            end
            local obj=walls[#walls]
            local y1=sector[1]*worldscale
            local y2=sector[2]*worldscale
            local height=(y2-y1)/worldscale
            local uvoffx=sidedef[1]/obj.width
            local uvoffy=-sidedef[2]/obj.height
            local width=length/obj.width+uvoffx
            height=-height/obj.height+uvoffy
            obj.shader.SetVector("pos1",{x2,y1,z2,1})
            obj.shader.SetVector("pos2",{x1,y1,z1,1})
            obj.shader.SetVector("pos3",{x2,y2,z2,1})
            obj.shader.SetVector("pos4",{x1,y2,z1,1})
            obj.shader.SetVector("uvpos12",{uvoffx,height,width,height})
            obj.shader.SetVector("uvpos34",{uvoffx,uvoffy,width,uvoffy})
        else
            local sector1=SECTORS[SIDEDEFS[LINEDEFS[i][6]+1][6]+1]
            local sector2=SECTORS[SIDEDEFS[LINEDEFS[i][7]+1][6]+1]
            local floormatch=false
            if sector1[1]-sector2[1]!=0 then
                local sidedef=SIDEDEFS[LINEDEFS[i][6]+1]
                local secttexture=sidedef[4]
                if secttexture!='-' then
                    walls[#walls+1]=cyf3dCreateQuad(texturespath..secttexture)
                    if definedtextureanims[secttexture]!=nil then
                        walls[#walls].SetAnimation(getanim(definedtextureanims,texturespath,secttexture),animspeed)
                    end
                    local obj=walls[#walls]
                    local y1=math.min(sector1[1],sector2[1])*worldscale
                    local y2=(sector1[1]+sector2[1])*worldscale-y1
                    local height=(y2-y1)/worldscale
                    local uvoffx=sidedef[1]/obj.width
                    local uvoffy=-sidedef[2]/obj.height
                    local width=length/obj.width+uvoffx
                    height=-height/obj.height+uvoffy
                    obj.shader.SetVector("pos1",{x1,y1,z1,1})
                    obj.shader.SetVector("pos2",{x2,y1,z2,1})
                    obj.shader.SetVector("pos3",{x1,y2,z1,1})
                    obj.shader.SetVector("pos4",{x2,y2,z2,1})
                    obj.shader.SetVector("uvpos12",{uvoffx,height,width,height})
                    obj.shader.SetVector("uvpos34",{uvoffx,uvoffy,width,uvoffy})
                else
                    sidedef=SIDEDEFS[LINEDEFS[i][7]+1]
                    secttexture=sidedef[4]
                    walls[#walls+1]=cyf3dCreateQuad(texturespath..secttexture)
                    if definedtextureanims[secttexture]!=nil then
                        walls[#walls].SetAnimation(getanim(definedtextureanims,texturespath,secttexture),animspeed)
                    end
                    local obj=walls[#walls]
                    local y1=math.min(sector1[1],sector2[1])*worldscale
                    local y2=(sector1[1]+sector2[1])*worldscale-y1
                    local height=(y2-y1)/worldscale
                    local uvoffx=sidedef[1]/obj.width
                    local uvoffy=-sidedef[2]/obj.height
                    local width=length/obj.width+uvoffx
                    height=-height/obj.height+uvoffy
                    obj.shader.SetVector("pos1",{x2,y1,z2,1})
                    obj.shader.SetVector("pos2",{x1,y1,z1,1})
                    obj.shader.SetVector("pos3",{x2,y2,z2,1})
                    obj.shader.SetVector("pos4",{x1,y2,z1,1})
                    obj.shader.SetVector("uvpos12",{uvoffx,height,width,height})
                    obj.shader.SetVector("uvpos34",{uvoffx,uvoffy,width,uvoffy})
                end
            else
                floormatch=true
            end
            if sector1[2]<sector2[2] then
                local sidedef=SIDEDEFS[LINEDEFS[i][7]+1]
                local secttexture=sidedef[3]
                if secttexture!='-' then
                    walls[#walls+1]=cyf3dCreateQuad(texturespath..secttexture)
                    if definedtextureanims[secttexture]!=nil then
                        walls[#walls].SetAnimation(getanim(definedtextureanims,texturespath,secttexture),animspeed)
                    end
                    local obj=walls[#walls]
                    local y1=sector1[2]*worldscale
                    local y2=sector2[2]*worldscale
                    local height=(y2-y1)/worldscale
                    local uvoffx=sidedef[1]/obj.width
                    local uvoffy=-sidedef[2]/obj.height
                    local width=length/obj.width+uvoffx
                    height=-height/obj.height+uvoffy
                    obj.shader.SetVector("pos1",{x2,y1,z2,1})
                    obj.shader.SetVector("pos2",{x1,y1,z1,1})
                    obj.shader.SetVector("pos3",{x2,y2,z2,1})
                    obj.shader.SetVector("pos4",{x1,y2,z1,1})
                    obj.shader.SetVector("uvpos12",{uvoffx,height,width,height})
                    obj.shader.SetVector("uvpos34",{uvoffx,uvoffy,width,uvoffy})
                end
            elseif sector1[2]>sector2[2] then
                if sector1[4]!="F_SKY1" or sector2[4]!="F_SKY1" then
                    local sidedef=SIDEDEFS[LINEDEFS[i][6]+1]
                    local secttexture=sidedef[3]
                    if secttexture!='-' then
                        walls[#walls+1]=cyf3dCreateQuad(texturespath..secttexture)
                        if definedtextureanims[secttexture]!=nil then
                            walls[#walls].SetAnimation(getanim(definedtextureanims,texturespath,secttexture),animspeed)
                        end
                        local obj=walls[#walls]
                        local y1=sector2[2]*worldscale
                        local y2=sector1[2]*worldscale
                        local height=(y2-y1)/worldscale
                        local uvoffx=sidedef[1]/obj.width
                        local uvoffy=-sidedef[2]/obj.height
                        local width=length/obj.width+uvoffx
                        height=-height/obj.height+uvoffy
                        obj.shader.SetVector("pos1",{x1,y1,z1,1})
                        obj.shader.SetVector("pos2",{x2,y1,z2,1})
                        obj.shader.SetVector("pos3",{x1,y2,z1,1})
                        obj.shader.SetVector("pos4",{x2,y2,z2,1})
                        obj.shader.SetVector("uvpos12",{uvoffx,height,width,height})
                        obj.shader.SetVector("uvpos34",{uvoffx,uvoffy,width,uvoffy})
                    end
                end
            else
                if floormatch then
                    local sidedef=SIDEDEFS[LINEDEFS[i][6]+1]
                    local secttexture=sidedef[5]
                    local y1=sector1[1]*worldscale
                    local y2=sector1[2]*worldscale
                    local fullheight=(y2-y1)/worldscale
                    if secttexture!='-' then
                        walls[#walls+1]=cyf3dCreateQuad(texturespath..secttexture)
                        if definedtextureanims[secttexture]!=nil then
                            walls[#walls].SetAnimation(getanim(definedtextureanims,texturespath,secttexture),animspeed)
                        end
                        local obj=walls[#walls]
                        local uvoffx=sidedef[1]/obj.width
                        local uvoffy=-sidedef[2]/obj.height
                        local width=length/obj.width+uvoffx
                        local height=-fullheight/obj.height+uvoffy
                        obj.shader.SetVector("pos1",{x1,y1,z1,1})
                        obj.shader.SetVector("pos2",{x2,y1,z2,1})
                        obj.shader.SetVector("pos3",{x1,y2,z1,1})
                        obj.shader.SetVector("pos4",{x2,y2,z2,1})
                        obj.shader.SetVector("uvpos12",{uvoffx,height,width,height})
                        obj.shader.SetVector("uvpos34",{uvoffx,uvoffy,width,uvoffy})
                    end
                    sidedef=SIDEDEFS[LINEDEFS[i][7]+1]
                    secttexture=sidedef[5]
                    if secttexture!='-' then
                        walls[#walls+1]=cyf3dCreateQuad(texturespath..secttexture)
                        if definedtextureanims[secttexture]!=nil then
                            walls[#walls].SetAnimation(getanim(definedtextureanims,texturespath,secttexture),animspeed)
                        end
                        local obj=walls[#walls]
                        local uvoffx=sidedef[1]/obj.width
                        local uvoffy=-sidedef[2]/obj.height
                        local width=length/obj.width+uvoffx
                        local height=-fullheight/obj.height+uvoffy
                        obj.shader.SetVector("pos1",{x2,y1,z2,1})
                        obj.shader.SetVector("pos2",{x1,y1,z1,1})
                        obj.shader.SetVector("pos3",{x2,y2,z2,1})
                        obj.shader.SetVector("pos4",{x1,y2,z1,1})
                        obj.shader.SetVector("uvpos12",{uvoffx,height,width,height})
                        obj.shader.SetVector("uvpos34",{uvoffx,uvoffy,width,uvoffy})
                    end
                end
            end
        end
    end

    LINEDEFS=nil
    SIDEDEFS=nil

    uvcoords={}
    vertcoords={}
    vertpairs={}
    for i=1,#VERTEXES do
        uvcoords[#uvcoords+1]={VERTEXES[i][1]*worldscale,VERTEXES[i][2]*worldscale}
        vertpairs[#vertpairs+1]={VERTEXES[i][1],VERTEXES[i][2]}
        vertcoords[#vertcoords+1]={vertpairs[#vertpairs][1]*worldscale,0,vertpairs[#vertpairs][2]*worldscale}
    end

    VERTEXES=nil

    for i=1,#TRIANGLES do
        if #TRIANGLES[i]!=0 then
            local floorheight=SECTORS[i][1]*worldscale
            local ceilheight=SECTORS[i][2]*worldscale
            local ceilexists=SECTORS[i][4]!="F_SKY1"
            local animfloor={}
            local animceil={}
            if definedflatanims[SECTORS[i][3]]~=nil then
                animfloor=getanim(definedflatanims,flatspath,SECTORS[i][3])
            end
            if ceilexists and definedflatanims[SECTORS[i][4]]~=nil then
                animceil=getanim(definedflatanims,flatspath,SECTORS[i][4])
            end
            local floorcoords={}
            for j=0,math.ceil(#TRIANGLES[i]/33)-1 do
                local floor=cyf3dCreate3DModel("WADs/"..wadname.."/Flats/"..SECTORS[i][3])
                if #animfloor!=0 then
                    floor.SetAnimation(animfloor,animspeed)
                end
                local ceil
                if ceilexists then
                    ceil=cyf3dCreate3DModel("WADs/"..wadname.."/Flats/"..SECTORS[i][4])
                    if #animceil!=0 then
                        ceil.SetAnimation(animceil,animspeed)
                    end
                end
                local joffset=j*33
                for k=1,math.min(#TRIANGLES[i]-joffset,33) do
                    local kthrice=(k-1)*3
                    local triid=joffset+k
                    local vert1=vertcoords[TRIANGLES[i][triid][1]]
                    local vert2=vertcoords[TRIANGLES[i][triid][2]]
                    local vert3=vertcoords[TRIANGLES[i][triid][3]]
                    floor.shader.SetVector("vert"..tostring(kthrice+1),{vert1[1],floorheight,vert1[3],1})
                    floor.shader.SetVector("vert"..tostring(kthrice+2),{vert2[1],floorheight,vert2[3],1})
                    floor.shader.SetVector("vert"..tostring(kthrice+3),{vert3[1],floorheight,vert3[3],1})
                    if ceilexists then
                        ceil.shader.SetVector("vert"..tostring(kthrice+1),{vert1[1],ceilheight,vert1[3],1})
                        ceil.shader.SetVector("vert"..tostring(kthrice+2),{vert2[1],ceilheight,vert2[3],1})
                        ceil.shader.SetVector("vert"..tostring(kthrice+3),{vert3[1],ceilheight,vert3[3],1})
                    end
                end
            end
        end
    end

    SECTORS=nil
    TRIANGLES=nil
end

local loading=true

function Update()
    if loading then
        local status,returnval=coroutine.resume(wadread,wadname)
        loadtext.SetText(textattrs..returnval)
        loading=returnval!="Finished loading"
        if not loading then
            CreateStuff()
            loadscreen.Remove()
            loadtext.Remove()
        end
    else
        spcosYaw=math.cos(math.rad(cyf3dcamerayrot))*speed
        spsinYaw=math.sin(math.rad(cyf3dcamerayrot))*speed
        spsinPitch=math.sin(math.rad(cyf3dcameraxrot))*speed
        cosPitch=math.cos(math.rad(cyf3dcameraxrot))
        if Input.GetKey("D")>=1 then
            cyf3dcamerax=cyf3dcamerax+spcosYaw
            cyf3dcameraz=cyf3dcameraz-spsinYaw
        end
        if Input.GetKey("A")>=1 then
            cyf3dcamerax=cyf3dcamerax-spcosYaw
            cyf3dcameraz=cyf3dcameraz+spsinYaw
        end
        if Input.GetKey("W")>=1 then
            cyf3dcamerax=cyf3dcamerax+spsinYaw*cosPitch
            cyf3dcameray=cyf3dcameray-spsinPitch
            cyf3dcameraz=cyf3dcameraz+spcosYaw*cosPitch
        end
        if Input.GetKey("S")>=1 then
            cyf3dcamerax=cyf3dcamerax-spsinYaw*cosPitch
            cyf3dcameray=cyf3dcameray+spsinPitch
            cyf3dcameraz=cyf3dcameraz-spcosYaw*cosPitch
        end
        if Input.GetKey("Q")>=1 then
            cyf3dcameray=cyf3dcameray-speed
        end
        if Input.GetKey("E")>=1 then
            cyf3dcameray=cyf3dcameray+speed
        end
        if Input.GetKey("UpArrow")>=1 then
            cyf3dcameraxrot=math.max(cyf3dcameraxrot-2,-90)
        end
        if Input.GetKey("DownArrow")>=1 then
            cyf3dcameraxrot=math.min(cyf3dcameraxrot+2,90)
        end
        if Input.GetKey("LeftArrow")>=1 then
            cyf3dcamerayrot=(cyf3dcamerayrot-2)%360
        end
        if Input.GetKey("RightArrow")>=1 then
            cyf3dcamerayrot=(cyf3dcamerayrot+2)%360
        end
        bg.shader.setFloat("xoff",cyf3dcamerayrot/360)
        cyf3dUpdateObjects()
    end
end
