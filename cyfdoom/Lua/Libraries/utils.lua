local utils = {}

require "math"

local max = math.max
local min = math.min
local sqrt = math.sqrt

function utils.sortBySecondValue(t1, t2)
    return t2[2] > t1[2]
end

function utils.squaredPointDistance(p1, p2)
    local xdiff = p2[1] - p1[1]
    local ydiff = p2[2] - p1[2]
    return (xdiff * xdiff) + (ydiff * ydiff)
end

function utils.pointDistance(p1, p2)
    return sqrt(utils.squaredPointDistance(p1, p2))
end

-- Source: https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
function utils.isPointBetweenPoints(p, p1, p2)
    local xmin = min(p1[1], p2[1])
    local xmax = max(p1[1], p2[1])

    local ymin = min(p1[2], p2[2])
    local ymax = max(p1[2], p2[2])

    local x = p[1]
    local y = p[2]

    return (xmin <= x and x <= xmax) and (ymin <= y and y <= ymax)
end

function utils.crossProduct(p1, p2, p3)
    return (p2[2] - p1[2]) * (p3[1] - p2[1]) - (p2[1] - p1[1]) * (p3[2] - p2[2])
end

function utils.arePointsCollinear(p1, p2, p3)
    --return utils.crossProduct(p1, p2, p3) == 0
    return (p2[2] - p1[2]) * (p3[1] - p2[1]) - (p2[1] - p1[1]) * (p3[2] - p2[2]) == 0
end

function utils.orientation(p1, p2, p3)
    --local pCross = utils.crossProduct(p1, p2, p3)
    local pCross = (p2[2] - p1[2]) * (p3[1] - p2[1]) - (p2[1] - p1[1]) * (p3[2] - p2[2])
    
    if pCross == 0 then
        return 0
    end

    return pCross > 0 and 1 or 2
end

function utils.isPointOnLineSegment(p, ls)
    local p1 = ls[1]
    local p2 = ls[2]

    return utils.arePointsCollinear(p, p1, p2) and utils.isPointBetweenPoints(p, p1, p2)
end

function utils.doLineSegmentsIntersect(ls1, ls2, genCase)
    genCase = genCase or false

    local orientation = utils.orientation
    --local isPointOnLineSegment = utils.isPointOnLineSegment
    local isPointBetweenPoints = utils.isPointBetweenPoints
    local ls1p1 = ls1[1]
    local ls1p2 = ls1[2]

    local ls2p1 = ls2[1]
    local ls2p2 = ls2[2]

    local o1 = orientation(ls1p1, ls1p2, ls2p1)
    local o2 = orientation(ls1p1, ls1p2, ls2p2)
    local o3 = orientation(ls2p1, ls2p2, ls1p1)
    local o4 = orientation(ls2p1, ls2p2, ls1p2)

    -- General case where if both points of each line are outside the other line in different relative directions - the lines must be interecting.
    if ((o1 != o2) and (o3 != o4)) then
        return true
    end

    if genCase then
        return false
    end

    -- Edge cases where the line segments are parallel, in which case an intersection only happens when one of the end points is on the other line segment.
    --if isPointOnLineSegment(ls2p1, ls1) then
    --    return true
    --end
    --if isPointOnLineSegment(ls2p2, ls1) then
    --    return true
    --end
    --if isPointOnLineSegment(ls1p1, ls2) then
    --    return true
    --end
    --if isPointOnLineSegment(ls1p2, ls2) then
    --    return true
    --end
    if (o1 == 0 and isPointBetweenPoints(ls2p1, ls1p1, ls1p2)) then
        return true
    end
    if (o2 == 0 and isPointBetweenPoints(ls2p2, ls1p1, ls1p2)) then
        return true
    end
    if (o3 == 0 and isPointBetweenPoints(ls1p1, ls2p1, ls2p2)) then
        return true
    end
    if (o4 == 0 and isPointBetweenPoints(ls1p2, ls2p1, ls2p2)) then
        return true
    end

    return false
end

return utils