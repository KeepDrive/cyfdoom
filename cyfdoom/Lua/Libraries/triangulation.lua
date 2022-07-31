-- My own homebrew triangulation library

return function(vertices, constraints)
    local atan2 = math.atan2
    local min = math.min
    local pi = math.pi
    local huge = math.huge

    local utils = require "utils"
    local doLineSegmentsIntersect = utils.doLineSegmentsIntersect
    local sortBySecondValue = utils.sortBySecondValue
    local pointDistance = utils.pointDistance
    local orientation = utils.orientation
    local arePointsCollinear = utils.arePointsCollinear
    utils = nil
    
    local hullEdgesCoords = {}
    local hullExistingEdges = {}
    local hullTris = {}
    
    for i = 1, #constraints do
        local constraint = constraints[i]
        local p1 = constraint[1]
        local p2 = constraint[2]
        hullEdgesCoords[i] = {vertices[p1], vertices[p2]}
        local pmin = min(p1, p2)
        if hullExistingEdges[pmin] == nil then
            hullExistingEdges[pmin] = {}
        end
        hullExistingEdges[pmin][p1 + p2 - pmin] = true
    end

    for i = 2, #vertices do
        local seenPoints = {}
        local p1 = vertices[i]
        for j = 1, i - 1 do
            local p2 = vertices[j]
            local newLineSeg = {p1, p2}
            local addLineSeg = true
            for k = 1, #hullEdgesCoords do
                local constraint = hullEdgesCoords[k]
                local p3 = constraint[1]
                local p4 = constraint[2]
                local check1 = (p3 == p1)
                local check2 = (p3 == p2)
                local check3 = (p4 == p1)
                local check4 = (p4 == p2)
                if (check1 and check4) or (check2 and check3) then
                    addLineSeg = false
                    break
                elseif not (check1 or check2 or check3 or check4) then
                    if doLineSegmentsIntersect(newLineSeg, constraint) then
                        addLineSeg = false
                        break
                    end
                end
            end
            if addLineSeg then
                seenPoints[#seenPoints + 1] = {j, atan2(p1[2]-p2[2], p1[1]-p2[1])}
            end
        end
        table.sort(seenPoints, sortBySecondValue)
        if #seenPoints == 1 then
            hullEdgesCoords[#hullEdgesCoords+1] = {p1, vertices[seenPoints[1][1]]}
            local pointMin = min(i, seenPoints[1][1])
            if hullExistingEdges[pointMin] == nil then
                hullExistingEdges[pointMin] = {}
            end
            hullExistingEdges[pointMin][i + seenPoints[1][1] - pointMin] = true
        else
            for j = 1, #seenPoints do
                local prevPoint = 0
                if j == 1 then
                    prevPoint = seenPoints[#seenPoints]
                else
                    prevPoint = seenPoints[j - 1]
                end
                local curPoint = seenPoints[j]
                hullEdgesCoords[#hullEdgesCoords + 1] = {p1, vertices[curPoint[1]]}
                local pointMin = min(i, curPoint[1])
                if hullExistingEdges[pointMin] == nil then
                    hullExistingEdges[pointMin] = {}
                end
                hullExistingEdges[pointMin][i + curPoint[1] - pointMin] = true
                local deg180 = pi
                if j == 1 then
                    deg180 = -pi
                end
                if curPoint[2] - prevPoint[2] < deg180 then
                    pointMin = min(prevPoint[1], curPoint[1])
                    if hullExistingEdges[pointMin][prevPoint[1] + curPoint[1] - pointMin] != nil then
                        local newTri = {i, prevPoint[1], curPoint[1]}
                        local p2 = vertices[prevPoint[1]]
                        local p3 = vertices[curPoint[1]]
                        local a = pointDistance(p1, p2)
                        local b = pointDistance(p2, p3)
                        local c = pointDistance(p1, p3)

                        local oneOverSum = 1 / (a + b + c)
                        local midPointX = (b * p1[1] + c * p2[1] + a * p3[1]) * oneOverSum
                        local midPointY = (b * p1[2] + c * p2[2] + a * p3[2]) * oneOverSum
                        local midPoint = {midPointX, midPointY}

                        local nearInfPoint = {huge, midPointY}
                        local nearInfLine = {midPoint, nearInfPoint}

                        local exactintersections = {}
                        local inters = 0
                        for j = 1, #constraints do
                            local constraint = constraints[j]
                            local vert1 = vertices[constraint[1]]
                            local vert2 = vertices[constraint[2]]

                            local exactintersect = false
                            if exactintersections[constraint[1]] != nil then
                                exactintersect = true
                                local orient1 = exactintersections[constraint[1]]
                                local orient2 = orientation(midPoint, vert1, vert2)
                                if orient1 != 0 and orient2 != 0 and orient1 != orient2 then
                                    inters = inters + 1
                                end
                            end
                            if exactintersections[constraint[2]] != nil then
                                exactintersect = true
                                local orient1 = exactintersections[constraint[2]]
                                local orient2 = orientation(midPoint, vert2, vert1)
                                if orient1 != 0 and orient2 != 0 and orient1 != orient2 then
                                    inters = inters + 1
                                end
                            end
                            if not exactintersect then
                                if doLineSegmentsIntersect({vert1, vert2}, nearInfLine) then
                                    if arePointsCollinear(midPoint, vert1, nearInfPoint) then
                                        exactintersections[constraint[1]] = orientation(midPoint, vert1, vert2)
                                        exactintersect = true
                                    end
                                    if arePointsCollinear(midPoint, vert2, nearInfPoint) then
                                        exactintersections[constraint[2]] = orientation(midPoint, vert2, vert1)
                                        exactintersect = true
                                    end
                                    if not exactintersect then
                                        inters = inters + 1
                                    end
                                end
                            end
                        end
                        if inters % 2 == 1 then
                            hullTris[#hullTris+1] = newTri
                        end
                    end
                end
            end
        end
    end
    return hullTris
end