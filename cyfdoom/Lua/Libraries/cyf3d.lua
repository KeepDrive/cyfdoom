--VERY modified version of cyf3d with only the stuff that is needed
local cyf3dobjects={}

cyf3dcamerax = 0
cyf3dcameray = 0
cyf3dcameraz = 0
cyf3dcameraxrot = 0
cyf3dcamerayrot = 0

local rad = math.rad
local sin = math.sin
local cos = math.cos
local tan = math.tan

local fov = 90
local near = 0.001
local far = 1000

local m11 = 1 / tan(rad(fov * 0.5))
local m00 = m11 * 0.75
local m22 = 0
local m23 = 0
if Misc.OSType == "Linux" then
    m22 = (far + near) / (near - far)
    m23 = 2 * far * near / (near - far)
else
    m22 = near / (far - near)
    m23 = far * near / (far - near)
end

function cyf3dUpdateObjects()
    if #cyf3dobjects == 0 then return end
    local x = rad(cyf3dcameraxrot)
    local y = rad(cyf3dcamerayrot)
    
    local xc = cos(x)
    local xs = sin(x)
    local yc = cos(y)
    local ys = sin(y)
    
    local xcys = xc * ys
    local xcyc = xc * yc
    
    --[1][2] contains y for sprite rotation
    --is 0 otherwise
    local cameraMVP = cyf3dobjects[1].shader.Matrix(
        {m00*yc,   y,     -m00*ys,  0},
        {m11*xs*ys,m11*xc,m11*xs*yc,0},
        {-m22*xcys,m22*xs,-m22*xcyc,0},
        {xcys,     -xs,   xcyc,     -xcys*cyf3dcamerax+xs*cyf3dcameray-xcyc*cyf3dcameraz}
    )
    cameraMVP[1, 4] = -cameraMVP[1, 1] * cyf3dcamerax - cameraMVP[1, 3] * cyf3dcameraz
    cameraMVP[2, 4] = -cameraMVP[2, 1] * cyf3dcamerax - cameraMVP[2, 2] * cyf3dcameray - cameraMVP[2, 3] * cyf3dcameraz
    cameraMVP[3, 4] = -cameraMVP[4, 4] * m22 + m23

    for i = 1, #cyf3dobjects do
        cyf3dobjects[i].shader.SetMatrix("MVP", cameraMVP)
    end
end

function cyf3dCreateObject(spritename, shader)
    local class = CreateSprite(spritename, "Top")
    
    if not pcall(class.shader.Set, "cyfdoom", shader) then
        DEBUG("cyfdoom " .. shader .. " shader failed to load")
        class.Remove()
        return
    end

    class.shader.SetWrapMode("repeat")
    
    cyf3dobjects[#cyf3dobjects + 1] = class
    
    return class
end