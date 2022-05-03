--Lua implementation of the sweephull triangulation algorithm(http://www.s-hull.org)
require "math"--for trigonometry, min/max, abs, huge and sqrt

local shull={}

--Line intersection code adapted from https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/

function shull.onSegment(p,q,r)
    return (q[1] <= math.max(p[1], r[1]) and q[1] >= math.min(p[1], r[1]) and q[2] <= math.max(p[2], r[2]) and q[2] >= math.min(p[2], r[2]))
end

function shull.orientation(p,q,r)
    local val = (q[2] - p[2]) * (r[1] - q[1]) - (q[1] - p[1]) * (r[2] - q[2])
    if (val == 0) then
        return 0
    end
    return val > 0 and 1 or 2
end

function shull.lineIntersection(lineA,lineB)
    local o1 = shull.orientation(lineA[1], lineA[2], lineB[1]);
    local o2 = shull.orientation(lineA[1], lineA[2], lineB[2]);
    local o3 = shull.orientation(lineB[1], lineB[2], lineA[1]);
    local o4 = shull.orientation(lineB[1], lineB[2], lineA[2]);
    if (o1 != o2 and o3 != o4) then
        return true
    end
    if (o1 == 0 and shull.onSegment(lineA[1], lineB[1], lineA[2])) then
        return true
    end
    if (o2 == 0 and shull.onSegment(lineA[1], lineB[2], lineA[2])) then
        return true
    end
    if (o3 == 0 and shull.onSegment(lineB[1], lineA[1], lineB[2])) then
        return true
    end
    if (o4 == 0 and shull.onSegment(lineB[1], lineA[2], lineB[2])) then
        return true
    end
    return false
end

function shull.sortBySecondValue(k1,k2)
    return k2[2]>k1[2]
end

--function shull.triarea(tri)
--    local a=math.sqrt((tri[1][1]-tri[2][1])^2+(tri[1][2]-tri[2][2])^2)
--    local b=math.sqrt((tri[1][1]-tri[3][1])^2+(tri[1][2]-tri[3][2])^2)
--    local c=math.sqrt((tri[3][1]-tri[2][1])^2+(tri[3][2]-tri[2][2])^2)
--    local halfperimeter=(a+b+c)*0.5
--    return math.sqrt(halfperimeter*(halfperimeter-a)*(halfperimeter-b)*(halfperimeter-c))
--end

function shull.triangulate(vertices,constraints)
    constraints = constraints or {}
    local x={}
    --1 is our first point, so we start from that
    local x0=1
    for i=2,#vertices do
        x[i-1]={i,(vertices[i][1]-vertices[x0][1])^2+(vertices[i][2]-vertices[x0][2])^2}
    end
    table.sort(x,shull.sortBySecondValue)
    --[1][2] now points to the closest point
    local xj=x[1][1]
    --Edge length for this side is the square root of the first value for our distance check
    local asqr=x[1][2]
    local a=math.sqrt(asqr)
    local bsqr=0
    local b=0
    local csqr=0
    local c=0
    --Now we look for a point that creates the smallest circumcircle
    local xk=0
    local circumradius=math.huge
    for i=2,#x do
        local testxk=x[i][1]
        --define b as x0-xk, c as xj-xk
        local testbsqr=x[i][2]
        local testb=math.sqrt(testbsqr)
        local testcsqr=(vertices[testxk][1]-vertices[xj][1])^2+(vertices[testxk][2]-vertices[xj][2])^2
        local testc=math.sqrt(testcsqr)
        local s=(a+testb+testc)/2
        local radius=(a*testb*testc)/(4*math.sqrt(s*(s-a)*(s-testb)*(s-testc)))
        if radius<circumradius then
            circumradius=radius
            xk=testxk
            bsqr=testbsqr
            b=testb
            csqr=testcsqr
            c=testc
        end
    end
    x=nil--No longer need that
    --Find circumcentre
    --Surprisingly, there's a proper formula that should account for most edge cases
    --I hope it does not give terribly inaccurate results, this part seems to be very important to get right
    local A=math.sin(2*math.acos((asqr+bsqr-csqr)/(2*a*b)))--Angle xj-x0-xk
    local B=math.sin(2*math.acos((asqr+csqr-bsqr)/(2*a*c)))--Angle x0-xj-xk
    local C=math.sin(2*math.acos((bsqr+csqr-asqr)/(2*b*c)))--Angle x0-xk-xj
    local oneoversum=1/(A+B+C)
    local circumcentrex=(vertices[x0][1]*A+vertices[xj][1]*B+vertices[xk][1]*C)*oneoversum
    local circumcentrey=(vertices[x0][2]*A+vertices[xj][2]*B+vertices[xk][2]*C)*oneoversum
    local hullpoints={x0,xj,xk}
    local hulledges={{x0,xj},{x0,xk},{xj,xk}}
    local hulltris={{x0,xj,xk}}
    local s={}
    for i=2,#vertices do
        if i!=xj and i!=xk then
            s[#s+1]={i,(vertices[i][1]-circumcentrex)^2+(vertices[i][2]-circumcentrey)^2}
        end
    end
    table.sort(s,shull.sortBySecondValue)
    for i=1,#s do
        local newpoint=s[i][1]
        local seenpoints={}
        for j=1,#hullpoints do
            local addedpoint=hullpoints[j]
            local addedge=true
            local newlineseg={vertices[addedpoint],vertices[newpoint]}
            for k=1,#hulledges do
                local edgepoint1=hulledges[k][1]
                local edgepoint2=hulledges[k][2]
                if edgepoint1!=addedpoint and edgepoint2!=addedpoint then
                    if shull.lineIntersection({vertices[edgepoint1],vertices[edgepoint2]},newlineseg) then
                        addedge=false
                        break
                    end
                end
            end
            if addedge then
                local nlsxoff=newlineseg[1][1]-newlineseg[2][1]
                local nlsyoff=newlineseg[1][2]-newlineseg[2][2]
                --If an existing point lies on the same half-line as newlineseg - we would only want to consider the closest one 
                for k=1,#seenpoints do
                    local testpoint=seenpoints[k][1]
                    if shull.orientation(newlineseg[1],newlineseg[2],vertices[testpoint])==0 then
                        if nlsxoff^2+nlsyoff^2<=(newlineseg[2][1]-vertices[testpoint][1])^2+(newlineseg[2][2]-vertices[testpoint][2])^2 then
                            table.remove(seenpoints,k)--unsafe but we break out right after so its fine
                        end
                        break
                    end
                end
                seenpoints[#seenpoints+1]={addedpoint,math.atan2(nlsyoff,nlsxoff),true}
            end
        end
        --"Seen" points from the new point are sorted radially
        --That way each pair of points form a valid triangle
        table.sort(seenpoints,shull.sortBySecondValue)
        for j=2,#seenpoints do
            local prevpoint=seenpoints[j-1]
            local curpoint=seenpoints[j]
            if curpoint[2]-prevpoint[2]<math.pi then--A triangle can't have an angle bigger than 180deg
                hulltris[#hulltris+1]={prevpoint[1],curpoint[1],newpoint}
                --Edges should only be added once
                if curpoint[3] then
                    hulledges[#hulledges+1]={newpoint,curpoint[1]}
                    curpoint[3]=false
                end
                if prevpoint[3] then
                    hulledges[#hulledges+1]={newpoint,prevpoint[1]}
                    prevpoint[3]=false
                end
            end
        end
        --Edge case where there could be a valid triangle at the ends of the table
        if #seenpoints>=2 then
            local firstpoint=seenpoints[1]
            local lastpoint=seenpoints[#seenpoints]
            if firstpoint[2]-lastpoint[2]<-math.pi then
                hulltris[#hulltris+1]={firstpoint[1],lastpoint[1],newpoint}
                if firstpoint[3] then
                    hulledges[#hulledges+1]={newpoint,firstpoint[1]}
                    firstpoint[3]=false
                end
                if lastpoint[3] then
                    hulledges[#hulledges+1]={newpoint,lastpoint[1]}
                    lastpoint[3]=false
                end
            end
        end
        hullpoints[#hullpoints+1]=newpoint
    end
    --Non-delanuay triangulation finished, to delanuay-fy it we would have to flip adjacent tri's
    --I don't really care much about that part
    --So now we apply the constraints
    --https://www.newcastle.edu.au/__data/assets/pdf_file/0019/22519/23_A-fast-algortithm-for-generating-constrained-Delaunay-triangulations.pdf
    for i=1,#constraints do
        local constraint=constraints[i]
        local intersections={}
        for j=1,#hulledges do
            local addededge=hulledges[j]
            local firstvert  = addededge[1]==constraint[1] or addededge[1]==constraint[2]
            local secondvert = addededge[2]==constraint[1] or addededge[2]==constraint[2]
            if firstvert and secondvert then
                break
            elseif not (firstvert or secondvert) then
                if shull.lineIntersection({vertices[constraint[1]],vertices[constraint[2]]},{vertices[addededge[1]],vertices[addededge[2]]}) then
                    intersections[#intersections+1]=j
                end
            end
        end
        while #intersections!=0 do
            for j=#intersections,1,-1 do--Go from the end to the start because we will be removing edges along the way
                local intersection=intersections[j]
                local p1=hulledges[intersection][1]
                local p2=hulledges[intersection][2]
                local firsttri=0
                local secondtri=0
                --Ideally there should always be two triangles that share an intersecting edge
                --If not - something has gone horribly, horribly wrong
                for k=1,#hulltris do
                    local tri=hulltris[k]
                    local firstvert  = tri[1]==p1 or tri[2]==p1 or tri[3]==p1
                    local secondvert = tri[1]==p2 or tri[2]==p2 or tri[3]==p2
                    if firstvert and secondvert then
                        if firsttri==0 then
                            firsttri=k
                        else
                            secondtri=k
                            break
                        end
                    end
                end
                --First we need to see if the given two triangles when combined give a convex shape
                --Clever little conditionless trick to get the points of the other diagonal
                local p3=hulltris[firsttri][1]+hulltris[firsttri][2]+hulltris[firsttri][3]-p1-p2
                local p4=hulltris[secondtri][1]+hulltris[secondtri][2]+hulltris[secondtri][3]-p1-p2
                local pos1=vertices[p1]
                local pos2=vertices[p2]
                local pos3=vertices[p3]
                local pos4=vertices[p4]
                --In a convex shape the diagonals intersect, meaning
                if shull.lineIntersection({pos3,pos4},{pos1,pos2}) then
                    --AND the ends of one diagonal are not on the other diagonal
                    local check1=shull.orientation(pos4,pos1,pos2)!=0
                    local check2=shull.orientation(pos3,pos1,pos2)!=0
                    local check3=shull.orientation(pos1,pos3,pos4)!=0
                    local check4=shull.orientation(pos2,pos3,pos4)!=0
                    if check1 and check2 and check3 and check4 then
                        hulltris[firsttri]={p3,p4,p1}
                        hulltris[secondtri]={p3,p4,p2}
                        hulledges[intersection]={p3,p4}
                        if p3==constraint[1] or p3==constraint[2] or p4==constraint[1] or p4==constraint[2] then
                            table.remove(intersections,j)
                        elseif not shull.lineIntersection({pos3,pos4},{vertices[constraint[1]],vertices[constraint[2]]}) then
                            table.remove(intersections,j)
                        end
                    end
                end
            end
        end
        --Again, no need to create a delanuay triangulation, so we can skip the restoration part
    end
    --Now we discard excess triangles
    for i=#hulltris,1,-1 do
        local p1=vertices[hulltris[i][1]]
        local p2=vertices[hulltris[i][2]]
        local p3=vertices[hulltris[i][3]]
        local a=math.sqrt((p1[1]-p2[1])^2+(p1[2]-p2[2])^2)
        local b=math.sqrt((p2[1]-p3[1])^2+(p2[2]-p3[2])^2)
        local c=math.sqrt((p1[1]-p3[1])^2+(p1[2]-p3[2])^2)
        local oneoversum=1/(a+b+c)
        local midpoint={(b*p1[1]+c*p2[1]+a*p3[1])*oneoversum,(b*p1[2]+c*p2[2]+a*p3[2])*oneoversum}
        local nearinfpoint={math.huge,midpoint[2]}
        local nearinfline={midpoint,nearinfpoint}
        local inters=0
        local exactintersections={}
        for j=1,#constraints do
            local constraint=constraints[j]
            local vert1=vertices[constraint[1]]
            local vert2=vertices[constraint[2]]
            local exactintersect=false
            if exactintersections[tostring(constraint[1])]!=nil then
                exactintersect=true
                local orient1=exactintersections[tostring(constraint[1])]
                local orient2=shull.orientation(midpoint,vert1,vert2)
                if orient1!=0 and orient2!=0 and orient1!=orient2 then
                    inters=inters+1
                end
            end
            if exactintersections[tostring(constraint[2])]!=nil then
                exactintersect=true
                local orient1=exactintersections[tostring(constraint[2])]
                local orient2=shull.orientation(midpoint,vert2,vert1)
                if orient1!=0 and orient2!=0 and orient1!=orient2 then
                    inters=inters+1
                end
            end
            if not exactintersect then
                if shull.lineIntersection({vert1,vert2},nearinfline) then
                    if shull.orientation(midpoint,vert1,nearinfpoint)==0 then
                        exactintersections[tostring(constraint[1])]=shull.orientation(midpoint,vert1,vert2)
                        exactintersect=true
                    end
                    if shull.orientation(midpoint,vert2,nearinfpoint)==0 then
                        exactintersections[tostring(constraint[2])]=shull.orientation(midpoint,vert2,vert1)
                        exactintersect=true
                    end
                    if not exactintersect then
                        inters=inters+1
                    end
                end
            end
        end
        if inters%2==0 then
            table.remove(hulltris,i)
        end
    end
    return hulltris
end

return shull