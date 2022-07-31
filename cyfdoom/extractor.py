import os
import math

#Line intersection code source: https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/

def isPointBetweenPoints(p, p1, p2):
    xmin = min(p1[0], p2[0])
    xmax = max(p1[0], p2[0])

    ymin = min(p1[1], p2[1])
    ymax = max(p1[1], p2[1])

    x = p[0]
    y = p[1]

    return (xmin <= x and x <= xmax) and (ymin <= y and y <= ymax)

def crossProduct(p1, p2, p3):
    return (p2[1] - p1[1]) * (p3[0] - p2[0]) - (p2[0] - p1[0]) * (p3[1] - p2[1])

def orientation(p1, p2, p3):
    pCross = crossProduct(p1, p2, p3)
    
    if pCross == 0:
        return 0
    elif pCross > 0:
        return 1
    else:
        return 2

def doLineSegmentsIntersect(ls1, ls2):
    ls1p1 = ls1[0]
    ls1p2 = ls1[1]

    ls2p1 = ls2[0]
    ls2p2 = ls2[1]

    o1 = orientation(ls1p1, ls1p2, ls2p1)
    o2 = orientation(ls1p1, ls1p2, ls2p2)
    o3 = orientation(ls2p1, ls2p2, ls1p1)
    o4 = orientation(ls2p1, ls2p2, ls1p2)

    # General case where if both points of each line are outside the other line in different relative directions - the lines must be interecting.
    if ((o1 != o2) and (o3 != o4)):
        return True

    # Edge cases where the line segments are parallel, in which case an intersection only happens when one of the end points is on the other line segment.
    if (o1 == 0 and isPointBetweenPoints(ls2p1, ls1p1, ls1p2)):
        return True
    if (o2 == 0 and isPointBetweenPoints(ls2p2, ls1p1, ls1p2)):
        return True
    if (o3 == 0 and isPointBetweenPoints(ls1p1, ls2p1, ls2p2)):
        return True
    if (o4 == 0 and isPointBetweenPoints(ls1p2, ls2p1, ls2p2)):
        return True

    return False

def readUnsignedInt(bytesarr):
    return int.from_bytes(bytesarr, "little", signed=False)

def readInt(bytesarr):
    return int.from_bytes(bytesarr, "little", signed=True)

def readString(bytesarr):
    try:
        return bytesarr.decode("ascii").strip('\x00')
    except:
        return '-'

wadsList=[]
for i in os.listdir():
    if i.lower().endswith(".wad"):
        wadsList.append(i)

if len(wadsList)==0:
    print("No WADs found, please ensure that the WAD is in the same folder as the extractor")
else:
    choiceMade = False
    while not choiceMade:
        print("Choose WAD to extract for cyfDOOM")
        for i in range(1, len(wadsList)+1):
            print(str(i) + " - " + wadsList[i - 1])
        wadIndex = int(input("Input: ")) - 1
        print(wadsList[wadIndex] + " chosen, cofirm?(Y/n)")
        choiceMade = (input("Input: ").lower() == 'y')
    wadName = wadsList[wadIndex][ : -4]
    print(wadName)
    print("What should be extracted?(If this is the first extraction of this WAD - select 1)")
    print("1 - Everything(Graphics, Maps)")
    print("2 - Graphics(Patches, Flats, Textures)")
    print("3 - Maps")
    choice = int(input("Input: "))
    if choice == 1 or choice == 2:
        from PIL import Image
        playpal = []
        os.makedirs("Lua/Libraries/WADs/" + wadName + "/Patches/", exist_ok = True)
        os.makedirs("Lua/Libraries/WADs/" + wadName + "/Sprites/", exist_ok = True)
        os.makedirs("Sprites/WADs/" + wadName + "/PyPatches/", exist_ok = True)
        os.makedirs("Sprites/WADs/" + wadName + "/Flats/", exist_ok = True)
        os.makedirs("Sprites/WADs/" + wadName + "/Sprites/", exist_ok = True)
        os.makedirs("Sprites/WADs/" + wadName + "/Textures/", exist_ok = True)
    if choice == 1 or choice == 3:
        import triangle
        os.makedirs("Lua/Libraries/WADs/" + wadName + "/Maps/", exist_ok = True)
    with open(wadsList[wadIndex], "rb") as wadFile:
        wad = wadFile.read()
        if wad[1] == 87 and wad[2] == 65 and wad[3] == 68:
            infotableofs = readUnsignedInt(wad[8 : 12])
            offset = 0
            lumps = []
            pnames = []
            textures = []
            while infotableofs + offset < len(wad):
                pnt = infotableofs + offset
                lumps.append((readUnsignedInt(wad[pnt : (pnt + 4)]), readUnsignedInt(wad[(pnt + 4) : (pnt + 8)]), readString(wad[(pnt + 8) : (pnt + 16)])))
                if lumps[-1][2] == "PNAMES":
                    st = lumps[-1][0] + 4
                    numpatches = readUnsignedInt(wad[(st - 4) : st])
                    for i in range(numpatches):
                        strst = st + (i * 8)
                        pnames.append(readString(wad[strst : (strst + 8)].upper()))
                offset += 16
            lpndx = -1
            for i in lumps:
                lpndx += 1
                if choice == 1 or choice == 2:
                    if i[2] == "PLAYPAL":
                        print("Reading palette")
                        for j in range(768):
                            playpal.append(wad[i[0] + j])
                    elif i[2] == "TEXTURE1" or i[2] == "TEXTURE2":
                        print("Reading texture data")
                        txstart = i[0]
                        numtextures = readUnsignedInt(wad[txstart : (txstart + 4)])
                        offsets = []
                        for j in range(numtextures):
                            offset = txstart + readUnsignedInt(wad[(txstart + (j * 4) + 4) : (txstart + (j * 4) + 8)])
                            name = readString(wad[offset : (offset + 8)])
                            #masked = readUnsignedInt(wad[(offset + 8) : (offset + 12)])
                            width = readUnsignedInt(wad[(offset + 12) : (offset + 14)])
                            height = readUnsignedInt(wad[(offset + 14) : (offset + 16)])
                            #columndirectory = readUnsignedInt(wad[(offset + 16) : (offset + 20)])
                            patchcount = readUnsignedInt(wad[(offset + 20) : (offset + 22)])
                            patcharr = []
                            for k in range(patchcount):
                                offpatch = offset + (k * 10) + 22
                                originx = readInt(wad[(offpatch) : (offpatch + 2)])
                                originy = readInt(wad[(offpatch + 2) : (offpatch + 4)])
                                patchid = readUnsignedInt(wad[(offpatch + 4) : (offpatch + 6)])
                                #stepdir = readUnsignedInt(wad[(offpatch + 6) : (offpatch + 8)])
                                #colormap = readUnsignedInt(wad[(offpatch + 8) : (offpatch + 10)])
                                patcharr.append([originx, originy, patchid])
                            textures.append([name, width, height, patcharr])
                    elif i[2] == "F_START":
                        for j in lumps[(lpndx + 1) : ]:
                            if j[2] == "F_END":
                                break
                            if j[2] != "F1_START" and j[2] != "F2_START" and j[2] != "F1_END" and j[2] != "F2_END":
                                print("Extracting flat " + j[2])
                                flatData = bytearray()
                                for k in range(4096):
                                    px =  wad[j[0] + k] * 3
                                    flatData.append(playpal[px])
                                    flatData.append(playpal[px + 1])
                                    flatData.append(playpal[px + 2])
                                image = Image.frombytes("RGB", (64, 64), bytes(flatData), "raw", "RGB")
                                image.save("Sprites/WADs/" + wadName + "/Flats/" + j[2] + ".png", "PNG")
                                image.close()
                    elif i[2] == "S_START":
                        for j in lumps[lpndx + 1 : ]:
                            if j[2] == "S_END":
                                break
                            print("Extracting sprite " + j[2])
                            spriteStart = j[0]
                            width = readUnsignedInt(wad[spriteStart : (spriteStart + 2)])
                            height = readUnsignedInt(wad[(spriteStart + 2) : (spriteStart + 4)])
                            loff = readInt(wad[(spriteStart + 4) : (spriteStart + 6)])
                            toff = readInt(wad[(spriteStart + 6) : (spriteStart + 8)])
                            picData = []
                            for k in range(width):
                                picData.append([])
                                for l in range(height):
                                    picData[-1].append(256)
                                postStart = spriteStart + readUnsignedInt(wad[spriteStart + (k * 4) + 8 : (spriteStart + (k * 4) + 12)])
                                if k < (width - 1):
                                    nextcol = spriteStart + readUnsignedInt(wad[(spriteStart + (k * 4) + 12) : (spriteStart + (k * 4) + 16)])
                                else:
                                    nextcol = j[0] + j[1]
                                while postStart < nextcol:
                                    topdelta = wad[postStart]
                                    length = wad[postStart + 1]
                                    if topdelta != 255:
                                        for l in range(min(length, height - topdelta)):
                                            pix = wad[postStart + l + 3]
                                            if pix == 255:
                                                break
                                            picData[-1][l + topdelta] = pix
                                    postStart += length + 4
                            rawData = bytearray()
                            for k in range(height):
                                    for l in range(width):
                                        if picData[l][k] == 256:
                                            rawData.append(0)
                                            rawData.append(0)
                                            rawData.append(0)
                                            rawData.append(0)
                                        else:
                                            pix = picData[l][k] * 3
                                            rawData.append(playpal[pix])
                                            rawData.append(playpal[pix + 1])
                                            rawData.append(playpal[pix + 2])
                                            rawData.append(255)
                            with open("Lua/Libraries/WADs/" + wadName + "/Sprites/" + j[2] + ".lua", 'w') as patchfile:
                                patchfile.write("return {")
                                patchfile.write(str(width))
                                patchfile.write(',')
                                patchfile.write(str(height))
                                patchfile.write(',')
                                patchfile.write(str(loff))
                                patchfile.write(',')
                                patchfile.write(str(toff))
                                patchfile.write("}")
                            image = Image.frombytes("RGBA", (width,height), bytes(rawData), "raw", "RGBA")
                            image.save("Sprites/WADs/" + wadName + "/Sprites/" + j[2] + ".png", "PNG")
                            image.close()
                    elif i[2] in pnames:
                        print("Extracting patch " + i[2])
                        patchStart = i[0]
                        width = readUnsignedInt(wad[patchStart : (patchStart + 2)])
                        height = readUnsignedInt(wad[(patchStart + 2) : (patchStart + 4)])
                        loff = readInt(wad[(patchStart + 4) : (patchStart + 6)])
                        toff = readInt(wad[(patchStart + 6) : (patchStart + 8)])
                        picData = []
                        for j in range(width):
                            picData.append([])
                            for k in range(height):
                                picData[-1].append(256)
                            postStart = patchStart + readUnsignedInt(wad[(patchStart + (j * 4) + 8) : (patchStart + (j * 4) + 12)])
                            if j < (width - 1):
                                nextcol = patchStart + readUnsignedInt(wad[(patchStart + (j * 4) + 12) : (patchStart + (j * 4) + 16)])
                            else:
                                nextcol = i[0] + i[1]
                            while postStart < nextcol:
                                topdelta = wad[postStart]
                                length = wad[postStart + 1]
                                if topdelta != 255:
                                    for k in range(min(length, height - topdelta)):
                                        pix = wad[postStart + k + 3]
                                        if pix == 255:
                                            break
                                        picData[-1][k + topdelta] = pix
                                postStart += length + 4 
                        rawData = bytearray()
                        with open("Lua/Libraries/WADs/" + wadName + "/Patches/" + i[2] + ".lua", 'w') as patchfile:
                            patchfile.write("return {")
                            patchfile.write(str(width))
                            patchfile.write(',')
                            patchfile.write(str(height))
                            patchfile.write(',')
                            patchfile.write(str(loff))
                            patchfile.write(',')
                            patchfile.write(str(toff))
                            for j in range(height):
                                for k in range(width):
                                    patchfile.write(',')
                                    patchfile.write(str(picData[k][j]))
                                    if picData[k][j] == 256:
                                        rawData.append(0)
                                        rawData.append(0)
                                        rawData.append(0)
                                        rawData.append(0)
                                    else:
                                        pix = picData[k][j] * 3
                                        rawData.append(playpal[pix])
                                        rawData.append(playpal[pix + 1])
                                        rawData.append(playpal[pix + 2])
                                        rawData.append(255)
                            patchfile.write("}")
                        image = Image.frombytes("RGBA", (width, height), bytes(rawData), "raw", "RGBA")
                        image.save("Sprites/WADs/" + wadName + "/PyPatches/" + i[2] + ".png", "PNG")
                        image.close()
                if choice == 1 or choice == 3:
                    if ((i[2][0] == "E" and i[2][1].isdigit() and i[2][2] == "M") or i[2][ : 3] == "MAP") and i[2][3].isdigit():
                        print("Extracting map " + i[2])
                        verts = []
                        lines = []
                        sides = []
                        sectors = []
                        things = []
                        replacer = {}
                        for j in lumps[lpndx + 1 : ]:
                            if j[2] == "BLOCKMAP":
                                break
                            elif j[2] == "VERTEXES":
                                for k in range(j[1] // 4):
                                    vxst = j[0] + (k * 4)
                                    newvert = (readInt(wad[vxst : (vxst + 2)]),readInt(wad[(vxst + 2) : (vxst + 4)]))
                                    try:
                                        oldvert = verts.index(newvert)
                                        replacer[len(verts)] = oldvert
                                        #We want to ignore any duplicated vertices
                                        #Otherwise the triangulator dies a painful death
                                    except:
                                        pass
                                    verts.append(newvert)
                            elif j[2] == "LINEDEFS":
                                for k in range(j[1] // 14):
                                    ldst = j[0] + (k * 14)
                                    lines.append(
                                        (
                                            readUnsignedInt(wad[ldst : (ldst + 2)]),
                                            readUnsignedInt(wad[(ldst + 2) : (ldst + 4)]),
                                            readInt(wad[(ldst + 4) : (ldst + 6)]),
                                            readInt(wad[(ldst + 6) : (ldst + 8)]),
                                            readInt(wad[(ldst + 8) : (ldst + 10)]),
                                            readUnsignedInt(wad[(ldst + 10) : (ldst + 12)]),
                                            readUnsignedInt(wad[(ldst + 12) : (ldst + 14)])
                                        )
                                    )
                            elif j[2] == "SIDEDEFS":
                                for k in range(j[1] // 30):
                                    sdst = j[0] + (k * 30)
                                    sides.append(
                                        (
                                            readInt(wad[sdst : (sdst + 2)]),
                                            readInt(wad[(sdst + 2) : (sdst + 4)]),
                                            readString(wad[(sdst + 4) : (sdst + 12)]),
                                            readString(wad[(sdst + 12) : (sdst + 20)]),
                                            readString(wad[(sdst + 20) : (sdst + 28)]),
                                            readUnsignedInt(wad[(sdst + 28) : (sdst + 30)])
                                        )
                                    )
                            elif j[2] == "SECTORS":
                                for k in range(j[1] // 26):
                                    scst = j[0] + (k * 26)
                                    sectors.append(
                                        (
                                            readInt(wad[scst : (scst + 2)]),
                                            readInt(wad[(scst + 2) : (scst + 4)]),
                                            readString(wad[(scst + 4) : (scst + 12)]),
                                            readString(wad[(scst + 12) : (scst + 20)]),
                                            readInt(wad[(scst + 20) : (scst + 22)]),
                                            readInt(wad[(scst + 22) : (scst + 24)]),
                                            readInt(wad[(scst + 24) : (scst + 26)])
                                        )
                                    )
                            elif j[2] == "THINGS":
                                for k in range(j[1] // 10):
                                    tnst = j[0] + (k * 10)
                                    things.append(
                                        [
                                            readInt(wad[tnst : (tnst + 2)]),
                                            '-',
                                            readInt(wad[(tnst + 2) : (tnst + 4)]),
                                            readInt(wad[(tnst + 4) : (tnst + 6)]),
                                            readUnsignedInt(wad[(tnst + 6) : (tnst + 8)]),
                                            readUnsignedInt(wad[(tnst + 8) : (tnst + 10)])
                                        ]
                                    )
                        sectorVerts = []
                        sectorLines = []
                        sectorTris = []
                        sectorBoxes = []
                        for j in sectors:
                            sectorVerts.append([])
                            sectorLines.append([])
                            sectorTris.append([])
                            sectorBoxes.append([])
                        for j in lines:
                            st = verts[j[0]]
                            en = verts[j[1]]
                            if j[0] in replacer.keys():
                                pointsonway = [(replacer[j[0]], 0)]
                            else:
                                pointsonway = [(j[0], 0)]
                            for p in range(len(verts)):
                                if p != j[0] and p != j[1] and p not in replacer.keys():
                                    mid = verts[p]
                                    if isPointBetweenPoints(st, mid, en) and crossProduct(st, mid, en) == 0:
                                        pointsonway.append((p, (mid[0] + st[0]) ** 2 + (mid[1] + st[1]) ** 2))
                            pointsonway.sort(key = lambda v : v[1])
                            if j[1] in replacer.keys():
                                pointsonway.append((replacer[j[1]], 0))
                            else:
                                pointsonway.append((j[1], 0))
                            sec1 = j[5] != 65535
                            sec2 = j[6] != 65535
                            lastpoint = pointsonway[0][0]
                            for k in range(1, len(pointsonway)):
                                newpoint = pointsonway[k][0]
                                if sec1:
                                    sec = sides[j[5]][5]
                                    if lastpoint not in sectorVerts[sec]:
                                        addlastpoint = len(sectorVerts[sec])
                                        sectorVerts[sec].append(lastpoint)
                                    else:
                                        addlastpoint = sectorVerts[sec].index(lastpoint)
                                    if newpoint not in sectorVerts[sec]:
                                        addnewpoint = len(sectorVerts[sec])
                                        sectorVerts[sec].append(newpoint)
                                    else:
                                        addnewpoint = sectorVerts[sec].index(newpoint)
                                    sectorLines[sec].append((addlastpoint, addnewpoint))
                                if sec2:
                                    sec = sides[j[6]][5]
                                    if lastpoint not in sectorVerts[sec]:
                                        addlastpoint = len(sectorVerts[sec])
                                        sectorVerts[sec].append(lastpoint)
                                    else:
                                        addlastpoint = sectorVerts[sec].index(lastpoint)
                                    if newpoint not in sectorVerts[sec]:
                                        addnewpoint = len(sectorVerts[sec])
                                        sectorVerts[sec].append(newpoint)
                                    else:
                                        addnewpoint = sectorVerts[sec].index(newpoint)
                                    sectorLines[sec].append((addlastpoint, addnewpoint))
                                lastpoint = newpoint
                        for sec in range(len(sectorLines)):
                            localvertices = []
                            xmin = 99999999
                            xmax = -99999999
                            ymin = 99999999
                            ymax = -99999999
                            for j in sectorVerts[sec]:
                                vert = verts[j]
                                if vert[0] < xmin:
                                    xmin = vert[0]
                                if vert[0] > xmax:
                                    xmax = vert[0]
                                if vert[1] < ymin:
                                    ymin = vert[1]
                                if vert[1] > ymax:
                                    ymax = vert[1]
                                localvertices.append(vert)
                            sectorBoxes[sec] = [xmin, xmax, ymin, ymax]
                            if len(sectorVerts[sec]) >= 3:
                                triangulation = triangle.triangulate({"vertices" : localvertices, "segments" : sectorLines[sec]}, 'cp')
                                hulltris = triangulation["triangles"].tolist()
                                for j in range(len(hulltris)):
                                    for k in range(3):
                                        if hulltris[j][k] < len(sectorVerts[sec]):
                                            hulltris[j][k] = sectorVerts[sec][hulltris[j][k]]
                                        else:
                                            verts.append(triangulation["vertices"][hulltris[j][k]])
                                            hulltris[j][k] = len(verts) - 1
                                for j in range(len(hulltris)-1, -1, -1):
                                    p1 = verts[hulltris[j][0]]
                                    p2 = verts[hulltris[j][1]]
                                    p3 = verts[hulltris[j][2]]
                                    a = math.dist(p1, p2)
                                    b = math.dist(p2, p3)
                                    c = math.dist(p1, p3)
                                    oneoversum = 1 / (a + b + c)
                                    midpoint = ((b * p1[0] + c * p2[0] + a * p3[0]) * oneoversum, (b * p1[1] + c * p2[1] + a * p3[1]) * oneoversum)
                                    nearinfpoint = (99999999, midpoint[1])
                                    nearinfline = (midpoint, nearinfpoint)
                                    inters = 0
                                    exactintersections = {}
                                    for line in sectorLines[sec]:
                                        constraint = (sectorVerts[sec][line[0]], sectorVerts[sec][line[1]])
                                        vert1 = verts[constraint[0]]
                                        vert2 = verts[constraint[1]]
                                        exactintersect = False
                                        if constraint[0] in exactintersections:
                                            exactintersect = True
                                            orient1 = exactintersections[constraint[0]]
                                            orient2 = orientation(midpoint, vert1, vert2)
                                            if orient1 != 0 and orient2 != 0 and orient1 != orient2:
                                                inters += 1
                                        if constraint[1] in exactintersections:
                                            exactintersect = True
                                            orient1 = exactintersections[constraint[1]]
                                            orient2 = orientation(midpoint, vert2, vert1)
                                            if orient1 != 0 and orient2 != 0 and orient1 != orient2:
                                                inters += 1
                                        if not exactintersect:
                                            if doLineSegmentsIntersect((vert1, vert2), nearinfline):
                                                if orientation(midpoint, vert1, nearinfpoint) == 0:
                                                    exactintersections[constraint[0]] = orientation(midpoint, vert1, vert2)
                                                    exactintersect = True
                                                if orientation(midpoint, vert2, nearinfpoint) == 0:
                                                    exactintersections[constraint[1]] = orientation(midpoint, vert2, vert1)
                                                    exactintersect = True
                                                if not exactintersect:
                                                    inters += 1
                                    if inters % 2 == 0:
                                        del hulltris[j]
                                sectorTris[sec] = hulltris
                        for j in things:
                            checksectors = []
                            point = (j[0], j[2])
                            for k in range(len(sectorBoxes)):
                                bbox = sectorBoxes[k]
                                if isPointBetweenPoints((bbox[0], bbox[2]), point, (bbox[1], bbox[3])):
                                    checksectors.append(k)
                            for k in range(len(checksectors) - 1):#We never need to check the last one since an object should always be inside a sector
                                sec = checksectors[k]
                                constraints = sectorLines[sec]
                                nearinfpoint = (99999999, point[1])
                                nearinfline = (point, nearinfpoint)
                                inters = 0
                                exactintersections = {}
                                for line in constraints:
                                    constraint = (sectorVerts[sec][line[0]], sectorVerts[sec][line[1]])
                                    vert1 = verts[constraint[0]]
                                    vert2 = verts[constraint[1]]
                                    exactintersect = False
                                    if constraint[0] in exactintersections:
                                        exactintersect = True
                                        orient1 = exactintersections[constraint[0]]
                                        orient2 = orientation(point,vert1,vert2)
                                        if orient1 != 0 and orient2 != 0 and orient1 != orient2:
                                            inters += 1
                                    if constraint[1] in exactintersections:
                                        exactintersect = True
                                        orient1 = exactintersections[constraint[1]]
                                        orient2 = orientation(point, vert2, vert1)
                                        if orient1 != 0 and orient2 != 0 and orient1 != orient2:
                                            inters += 1
                                    if not exactintersect:
                                        if doLineSegmentsIntersect((vert1, vert2), nearinfline):
                                            if orientation(point, vert1, nearinfpoint) == 0:
                                                exactintersections[constraint[0]] = orientation(point, vert1, vert2)
                                                exactintersect = True
                                            if orientation(point, vert2, nearinfpoint) == 0:
                                                exactintersections[constraint[1]] = orientation(point, vert2, vert1)
                                                exactintersect = True
                                            if not exactintersect:
                                                inters += 1
                                if inters % 2 == 1:
                                    j[1] = sectors[checksectors[k]][0]
                                    break
                            if j[1] == '-':
                                j[1] = sectors[checksectors[-1]][0]
                        with open("Lua/Libraries/WADs/" + wadName + "/Maps/" + i[2] + ".lua", 'w') as mapfile:
                            mapfile.write('return {VERTEXES={')
                            dontaddcomma = True
                            for j in verts:
                                if dontaddcomma:
                                    mapfile.write("{")
                                    dontaddcomma = False
                                else:
                                    mapfile.write(",{")
                                mapfile.write(str(j[0]))
                                mapfile.write(',')
                                mapfile.write(str(j[1]))
                                mapfile.write("}")
                            mapfile.write('},LINEDEFS={')
                            dontaddcomma = True
                            for j in lines:
                                if dontaddcomma:
                                    mapfile.write("{")
                                    dontaddcomma = False
                                else:
                                    mapfile.write(",{")
                                mapfile.write(str(j[0]))
                                mapfile.write(',')
                                mapfile.write(str(j[1]))
                                mapfile.write(',')
                                mapfile.write(str(j[2]))
                                mapfile.write(',')
                                mapfile.write(str(j[3]))
                                mapfile.write(',')
                                mapfile.write(str(j[4]))
                                mapfile.write(',')
                                mapfile.write(str(j[5]))
                                mapfile.write(',')
                                mapfile.write(str(j[6]))
                                mapfile.write("}")
                            mapfile.write('},SIDEDEFS={')
                            dontaddcomma = True
                            for j in sides:
                                if dontaddcomma:
                                    mapfile.write("{")
                                    dontaddcomma = False
                                else:
                                    mapfile.write(",{")
                                mapfile.write(str(j[0]))
                                mapfile.write(',')
                                mapfile.write(str(j[1]))
                                mapfile.write(',')
                                mapfile.write('"' + j[2] + '"')
                                mapfile.write(',')
                                mapfile.write('"' + j[3] + '"')
                                mapfile.write(',')
                                mapfile.write('"' + j[4] + '"')
                                mapfile.write(',')
                                mapfile.write(str(j[5]))
                                mapfile.write("}")
                            mapfile.write('},SECTORS={')
                            dontaddcomma = True
                            for j in sectors:
                                if dontaddcomma:
                                    mapfile.write("{")
                                    dontaddcomma = False
                                else:
                                    mapfile.write(",{")
                                mapfile.write(str(j[0]))
                                mapfile.write(',')
                                mapfile.write(str(j[1]))
                                mapfile.write(',')
                                mapfile.write('"'+j[2]+'"')
                                mapfile.write(',')
                                mapfile.write('"'+j[3]+'"')
                                mapfile.write(',')
                                mapfile.write(str(j[4]))
                                mapfile.write(',')
                                mapfile.write(str(j[5]))
                                mapfile.write(',')
                                mapfile.write(str(j[6]))
                                mapfile.write("}")
                            mapfile.write('},THINGS={')
                            dontaddcomma = True
                            for j in things:
                                if dontaddcomma:
                                    mapfile.write("{")
                                    dontaddcomma = False
                                else:
                                    mapfile.write(",{")
                                mapfile.write(str(j[0]))
                                mapfile.write(',')
                                mapfile.write(str(j[1]))
                                mapfile.write(',')
                                mapfile.write(str(j[2]))
                                mapfile.write(',')
                                mapfile.write(str(j[3]))
                                mapfile.write(',')
                                mapfile.write(str(j[4]))
                                mapfile.write("}")
                            mapfile.write('},TRIANGLES={')
                            dontaddcomma = True
                            for j in sectorTris:
                                if dontaddcomma:
                                    mapfile.write("{")
                                    dontaddcomma = False
                                else:
                                    mapfile.write(",{")
                                dontaddcomma2 = True
                                for k in j:
                                    if dontaddcomma2:
                                        mapfile.write("{")
                                        dontaddcomma2 = False
                                    else:
                                        mapfile.write(",{")
                                    mapfile.write(str(k[0] + 1))
                                    mapfile.write(',')
                                    mapfile.write(str(k[1] + 1))
                                    mapfile.write(',')
                                    mapfile.write(str(k[2] + 1))
                                    mapfile.write("}")
                                mapfile.write("}")
                            mapfile.write("}}")
            if choice == 1 or choice == 2:
                for i in textures:
                    print("Extracting texture " + i[0])
                    tex = Image.new("RGBA", (i[1], i[2]))
                    for j in i[3]:
                        patchimg = Image.open("Sprites/WADs/" + wadName + "/PyPatches/" + pnames[j[2]] + ".png")
                        tex.alpha_composite(patchimg, (j[0], j[1]))
                    tex.save("Sprites/WADs/" + wadName + "/Textures/" + i[0] + ".png", "PNG")
        else:
            print("WAD not identified")
