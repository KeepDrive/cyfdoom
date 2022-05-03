--VERY modified version of cyf3d with only the stuff that is needed
--And the stuff there is is cut down to the basics so performance is as good as can be
local cyf3dobjects={}
local cyf3dsprites={}

cyf3dcamerax=0
cyf3dcameray=0
cyf3dcameraz=0
cyf3dcameraxrot=0
cyf3dcamerayrot=0

local rad=math.rad
local sin=math.sin
local cos=math.cos
local tan=math.tan

local fov=90
local near=0.001
local far=1000

local m11 = 1/tan(rad(fov*0.5))
local m00 = m11*0.75
local m22 = 0
local m23 = 0
if Misc.OSType=="Linux" then
    m22 = (far+near)/(near-far)
    m23 = 2*far*near/(near-far)
else
    m22 = near/(far-near)
    m23 = far*near/(far-near)
end

function cyf3dUpdateObjects()
    if #cyf3dobjects!=0 then
        local x =rad(cyf3dcameraxrot)
        local y =rad(cyf3dcamerayrot)
        local xc=cos(x)
        local xs=sin(x)
        local yc=cos(y)
        local ys=sin(y)
        local xcys=xc*ys
        local xcyc=xc*yc
        local cyf3dcameraMVP={{m00*yc,0,-m00*ys,0},
                {m11*xs*ys,m11*xc,m11*xs*yc,0},
                {-m22*xcys,m22*xs,-m22*xcyc,0},
                {xcys,-xs,xcyc,-xcys*cyf3dcamerax+xs*cyf3dcameray-xcyc*cyf3dcameraz}}
        cyf3dcameraMVP[1][4]=-cyf3dcameraMVP[1][1]*cyf3dcamerax-cyf3dcameraMVP[1][3]*cyf3dcameraz
        cyf3dcameraMVP[2][4]=-cyf3dcameraMVP[2][1]*cyf3dcamerax-cyf3dcameraMVP[2][2]*cyf3dcameray-cyf3dcameraMVP[2][3]*cyf3dcameraz
        cyf3dcameraMVP[3][4]=-cyf3dcameraMVP[4][4]*m22+m23
        cyf3dcameraMVP=cyf3dobjects[1].shader.Matrix(cyf3dcameraMVP[1],cyf3dcameraMVP[2],cyf3dcameraMVP[3],cyf3dcameraMVP[4])
        for i=1,#cyf3dobjects do
            cyf3dobjects[i].shader.SetMatrix("MVP",cyf3dcameraMVP)
        end
        for i=1,#cyf3dsprites do
            cyf3dsprites[i].shader.SetFloat("yc",yc)
            cyf3dsprites[i].shader.SetFloat("ys",ys)
        end
    end
end

function cyf3dCreate3DSprite(spritename)
    local class=CreateSprite(spritename,"Top")
    if not pcall(class.shader.Set,"cyfdoom","DoomSprite") then
        DEBUG("cyfdoom DoomSprite shader failed to load")
        class.Remove()
        return nil
    end
    class.shader.SetWrapMode("repeat")
    cyf3dobjects[#cyf3dobjects+1]=class
    cyf3dsprites[#cyf3dsprites+1]=class
    return class
end

function cyf3dCreateQuad(spritename)
    local class=CreateSprite(spritename,"Top")
    if not pcall(class.shader.Set,"cyfdoom","DoomWall") then
        DEBUG("cyfdoom DoomWall shader failed to load")
        class.Remove()
        return nil
    end
    class.shader.SetWrapMode("repeat")
    cyf3dobjects[#cyf3dobjects+1]=class
    return class
end

function cyf3dCreate3DModel(texturepath)
    local class=CreateSprite(texturepath,"Top")
    if not pcall(class.shader.Set,"cyfdoom","DoomFloor") then
        DEBUG("cyfdoom DoomFloor shader failed to load")
        class.Remove()
        return nil
    end
    class.shader.SetWrapMode("repeat")
    cyf3dobjects[#cyf3dobjects+1]=class
    return class
end
