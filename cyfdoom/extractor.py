import os
import math

#Line intersection code source: https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/

def onSegment(p,q,r):
    return (q[0] <= max(p[0], r[0]) and q[0] >= min(p[0], r[0]) and q[1] <= max(p[1], r[1]) and q[1] >= min(p[1], r[1]))

def cross(p1,p2,p3):
    return (p2[0]-p1[0])*(p3[1]-p1[1])-(p2[1]-p1[1])*(p3[0]-p1[0])

def orientation(p,q,r):
    val = cross(p,q,r)
    if val == 0:
        return 0
    elif val > 0:
        return 1
    return 2

def lineIntersection(lineA,lineB):
    o1 = orientation(lineA[0], lineA[1], lineB[0]);
    o2 = orientation(lineA[0], lineA[1], lineB[1]);
    o3 = orientation(lineB[0], lineB[1], lineA[0]);
    o4 = orientation(lineB[0], lineB[1], lineA[1]);
    if (o1 != o2 and o3 != o4):
        return True
    if (o1 == 0 and onSegment(lineA[0], lineB[0], lineA[1])):
        return True
    if (o2 == 0 and onSegment(lineA[0], lineB[1], lineA[1])):
        return True
    if (o3 == 0 and onSegment(lineB[0], lineA[0], lineB[1])):
        return True
    if (o4 == 0 and onSegment(lineB[0], lineA[1], lineB[1])):
        return True
    return False

def readUnsignedInt(bytesarr):
    return int.from_bytes(bytesarr,"little",signed=False)

def readInt(bytesarr):
    return int.from_bytes(bytesarr,"little",signed=True)

def readString(bytesarr):
    try:
        return bytesarr.decode("ascii").strip('\x00')
    except:
        return '-'

wadslist=[]
for i in os.listdir():
    if i.lower().endswith(".wad"):
        wadslist.append(i)

if len(wadslist)==0:
    print("No WADs found, please ensure that the WAD is in the same folder as the extractor")
else:
    choice=False
    while not choice:
        print("Choose WAD to extract for cyfDOOM")
        for i in range(1,len(wadslist)+1):
            print(str(i)+" - "+wadslist[i-1])
        wadid=int(input("Input: "))-1
        print(wadslist[wadid]+" chosen, cofirm?(Y/n)")
        choice = input("Input: ").lower()=='y'
    wadname=wadslist[wadid][:-4]
    print(wadname)
    print("What should be extracted?(If this is the first extraction of this WAD - select 1)")
    print("1 - Everything(Graphics, maps)")
    print("2 - Graphics(patches, flats, textures)")
    print("3 - Maps")
    choice=int(input("Input: "))
    if choice==1 or choice==2:
        from PIL import Image
        playpal=[]
        os.makedirs("Lua/Libraries/WADs/"+wadname+"/Patches/", exist_ok = True)
        os.makedirs("Lua/Libraries/WADs/"+wadname+"/Sprites/", exist_ok = True)
        os.makedirs("Sprites/WADs/"+wadname+"/PyPatches/", exist_ok = True)
        os.makedirs("Sprites/WADs/"+wadname+"/Flats/", exist_ok = True)
        os.makedirs("Sprites/WADs/"+wadname+"/Sprites/", exist_ok = True)
        os.makedirs("Sprites/WADs/"+wadname+"/Textures/", exist_ok = True)
    if choice==1 or choice==3:
        import triangle
        os.makedirs("Lua/Libraries/WADs/"+wadname+"/Maps/", exist_ok = True)
    with open(wadslist[wadid],"rb") as wadfile:
        wad=wadfile.read()
        if wad[1]==87 and wad[2]==65 and wad[3]==68:
            infotableofs=readUnsignedInt(wad[8:12])
            offset=0
            lumps=[]
            pnames=[]
            textures=[]
            while infotableofs+offset<len(wad):
                pnt=infotableofs+offset
                lumps.append((readUnsignedInt(wad[pnt:pnt+4]),readUnsignedInt(wad[pnt+4:pnt+8]),readString(wad[pnt+8:pnt+16])))
                if lumps[-1][2]=="PNAMES":
                    st=lumps[-1][0]+4
                    numpatches=readUnsignedInt(wad[st-4:st])
                    for i in range(numpatches):
                        strst=st+i*8
                        pnames.append(readString(wad[strst:strst+8].upper()))
                offset+=16
            lpndx=-1
            for i in lumps:
                lpndx+=1
                if choice==1 or choice==2:
                    if i[2]=="PLAYPAL":
                        print("Reading pallete")
                        for j in range(768):
                            playpal.append(wad[i[0]+j])
                    elif i[2]=="TEXTURE1" or i[2]=="TEXTURE2":
                        print("Reading texture data")
                        txstart=i[0]
                        numtextures=readUnsignedInt(wad[txstart:txstart+4])
                        offsets=[]
                        for j in range(numtextures):
                            offset=txstart+readUnsignedInt(wad[txstart+j*4+4:txstart+j*4+8])
                            name=readString(wad[offset:offset+8])
                            #masked=readUnsignedInt(wad[offset+8:offset+12])
                            width=readUnsignedInt(wad[offset+12:offset+14])
                            height=readUnsignedInt(wad[offset+14:offset+16])
                            #columndirectory=readUnsignedInt(wad[offset+16:offset+20])
                            patchcount=readUnsignedInt(wad[offset+20:offset+22])
                            patcharr=[]
                            for k in range(patchcount):
                                offpatch=offset+22+k*10
                                originx=readInt(wad[offpatch:offpatch+2])
                                originy=readInt(wad[offpatch+2:offpatch+4])
                                patchid=readUnsignedInt(wad[offpatch+4:offpatch+6])
                                #stepdir=readUnsignedInt(wad[offpatch+6:offpatch+8])
                                #colormap=readUnsignedInt(wad[offpatch+8:offpatch+10])
                                patcharr.append([originx,originy,patchid])
                            textures.append([name,width,height,patcharr])
                    elif i[2]=="F_START":
                        for j in lumps[lpndx+1:]:
                            if j[2]=="F_END":
                                break
                            if j[2]!="F1_START" and j[2]!="F2_START" and j[2]!="F1_END" and j[2]!="F2_END":
                                print("Extracting flat "+j[2])
                                flatdata=bytearray()
                                for k in range(4096):
                                    px=wad[j[0]+k]*3
                                    flatdata.append(playpal[px])
                                    flatdata.append(playpal[px+1])
                                    flatdata.append(playpal[px+2])
                                image = Image.frombytes("RGB", (64,64), bytes(flatdata), "raw","RGB")
                                image.save("Sprites/WADs/"+wadname+"/Flats/"+j[2]+".png","PNG")
                                image.close()
                    elif i[2]=="S_START":
                        for j in lumps[lpndx+1:]:
                            if j[2]=="S_END":
                                break
                            print("Extracting sprite "+j[2])
                            spritest=j[0]
                            width=readUnsignedInt(wad[spritest:spritest+2])
                            height=readUnsignedInt(wad[spritest+2:spritest+4])
                            loff=readInt(wad[spritest+4:spritest+6])
                            toff=readInt(wad[spritest+6:spritest+8])
                            picdata=[]
                            for k in range(width):
                                picdata.append([])
                                for l in range(height):
                                    picdata[-1].append(256)
                                poststart=spritest+readUnsignedInt(wad[spritest+k*4+8:spritest+k*4+12])
                                if k<width-1:
                                    nextcol=spritest+readUnsignedInt(wad[spritest+k*4+12:spritest+k*4+16])
                                else:
                                    nextcol=j[0]+j[1]
                                while poststart<nextcol:
                                    topdelta=wad[poststart]
                                    length=wad[poststart+1]
                                    if topdelta!=255:
                                        for l in range(min(length,height-topdelta)):
                                            pix=wad[poststart+l+3]
                                            if pix==255:
                                                break
                                            picdata[-1][l+topdelta]=pix
                                    poststart+=4+length
                            rawdata=bytearray()
                            for k in range(height):
                                    for l in range(width):
                                        if picdata[l][k]==256:
                                            rawdata.append(0)
                                            rawdata.append(0)
                                            rawdata.append(0)
                                            rawdata.append(0)
                                        else:
                                            pix=picdata[l][k]*3
                                            rawdata.append(playpal[pix])
                                            rawdata.append(playpal[pix+1])
                                            rawdata.append(playpal[pix+2])
                                            rawdata.append(255)
                            with open("Lua/Libraries/WADs/"+wadname+"/Sprites/"+j[2]+".lua",'w') as patchfile:
                                patchfile.write("return {")
                                patchfile.write(str(width))
                                patchfile.write(',')
                                patchfile.write(str(height))
                                patchfile.write(',')
                                patchfile.write(str(loff))
                                patchfile.write(',')
                                patchfile.write(str(toff))
                                patchfile.write("}")
                            image = Image.frombytes("RGBA", (width,height), bytes(rawdata), "raw","RGBA")
                            image.save("Sprites/WADs/"+wadname+"/Sprites/"+j[2]+".png","PNG")
                            image.close()
                    elif i[2] in pnames:
                        print("Extracting patch "+i[2])
                        patchst=i[0]
                        width=readUnsignedInt(wad[patchst:patchst+2])
                        height=readUnsignedInt(wad[patchst+2:patchst+4])
                        loff=readInt(wad[patchst+4:patchst+6])
                        toff=readInt(wad[patchst+6:patchst+8])
                        picdata=[]
                        for j in range(width):
                            picdata.append([])
                            for k in range(height):
                                picdata[-1].append(256)
                            poststart=patchst+readUnsignedInt(wad[patchst+j*4+8:patchst+j*4+12])
                            if j<width-1:
                                nextcol=patchst+readUnsignedInt(wad[patchst+j*4+12:patchst+j*4+16])
                            else:
                                nextcol=i[0]+i[1]
                            while poststart<nextcol:
                                topdelta=wad[poststart]
                                length=wad[poststart+1]
                                if topdelta!=255:
                                    for k in range(min(length,height-topdelta)):
                                        pix=wad[poststart+k+3]
                                        if pix==255:
                                            break
                                        picdata[-1][k+topdelta]=pix
                                poststart+=4+length
                        rawdata=bytearray()
                        with open("Lua/Libraries/WADs/"+wadname+"/Patches/"+i[2]+".lua",'w') as patchfile:
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
                                    patchfile.write(str(picdata[k][j]))
                                    if picdata[k][j]==256:
                                        rawdata.append(0)
                                        rawdata.append(0)
                                        rawdata.append(0)
                                        rawdata.append(0)
                                    else:
                                        pix=picdata[k][j]*3
                                        rawdata.append(playpal[pix])
                                        rawdata.append(playpal[pix+1])
                                        rawdata.append(playpal[pix+2])
                                        rawdata.append(255)
                            patchfile.write("}")
                        image = Image.frombytes("RGBA", (width,height), bytes(rawdata), "raw","RGBA")
                        image.save("Sprites/WADs/"+wadname+"/PyPatches/"+i[2]+".png","PNG")
                        image.close()
                if choice==1 or choice==3:
                    if ((i[2][0]=="E" and i[2][1].isdigit() and i[2][2]=="M")or i[2][:3]=="MAP") and i[2][3].isdigit():
                        print("Extracting map "+i[2])
                        verts=[]
                        lines=[]
                        sides=[]
                        sectors=[]
                        things=[]
                        replacer={}
                        for j in lumps[lpndx+1:]:
                            if j[2]=="BLOCKMAP":
                                break
                            elif j[2]=="VERTEXES":
                                for k in range(j[1]//4):
                                    vxst=j[0]+k*4
                                    newvert=(readInt(wad[vxst:vxst+2]),readInt(wad[vxst+2:vxst+4]))
                                    try:
                                        oldvert=verts.index(newvert)
                                        replacer[len(verts)]=oldvert
                                        #We want to ignore any duplicated vertices
                                        #Otherwise the triangulator dies a painful death
                                    except:
                                        pass
                                    verts.append(newvert)
                            elif j[2]=="LINEDEFS":
                                for k in range(j[1]//14):
                                    ldst=j[0]+k*14
                                    lines.append((readUnsignedInt(wad[ldst:ldst+2]),readUnsignedInt(wad[ldst+2:ldst+4]),readInt(wad[ldst+4:ldst+6]),readInt(wad[ldst+6:ldst+8]),readInt(wad[ldst+8:ldst+10]),readUnsignedInt(wad[ldst+10:ldst+12]),readUnsignedInt(wad[ldst+12:ldst+14])))
                            elif j[2]=="SIDEDEFS":
                                for k in range(j[1]//30):
                                    sdst=j[0]+k*30
                                    sides.append((readInt(wad[sdst:sdst+2]),readInt(wad[sdst+2:sdst+4]),readString(wad[sdst+4:sdst+12]),readString(wad[sdst+12:sdst+20]),readString(wad[sdst+20:sdst+28]),readUnsignedInt(wad[sdst+28:sdst+30])))
                            elif j[2]=="SECTORS":
                                for k in range(j[1]//26):
                                    scst=j[0]+k*26
                                    sectors.append((readInt(wad[scst:scst+2]),readInt(wad[scst+2:scst+4]),readString(wad[scst+4:scst+12]),readString(wad[scst+12:scst+20]),readInt(wad[scst+20:scst+22]),readInt(wad[scst+22:scst+24]),readInt(wad[scst+24:scst+26])))
                            elif j[2]=="THINGS":
                                for k in range(j[1]//10):
                                    tnst=j[0]+k*10
                                    things.append([readInt(wad[tnst:tnst+2]),'-',readInt(wad[tnst+2:tnst+4]),readInt(wad[tnst+4:tnst+6]),readUnsignedInt(wad[tnst+6:tnst+8]),readUnsignedInt(wad[tnst+8:tnst+10])])
                        sectorverts=[]
                        sectorlines=[]
                        sectortris=[]
                        sectorboxes=[]
                        for j in sectors:
                            sectorverts.append([])
                            sectorlines.append([])
                            sectortris.append([])
                            sectorboxes.append([])
                        for j in lines:
                            st=verts[j[0]]
                            en=verts[j[1]]
                            if j[0] in replacer.keys():
                                pointsonway=[(replacer[j[0]],0)]
                            else:
                                pointsonway=[(j[0],0)]
                            for p in range(len(verts)):
                                if p != j[0] and p != j[1] and p not in replacer.keys():
                                    mid=verts[p]
                                    if onSegment(st,mid,en) and cross(st,mid,en)==0:
                                        pointsonway.append((p,(mid[0]+st[0])**2+(mid[1]+st[1])**2))
                            pointsonway.sort(key=lambda v : v[1])
                            if j[1] in replacer.keys():
                                pointsonway.append((replacer[j[1]],0))
                            else:
                                pointsonway.append((j[1],0))
                            sec1=j[5]!=65535
                            sec2=j[6]!=65535
                            lastpoint=pointsonway[0][0]
                            for k in range(1,len(pointsonway)):
                                newpoint=pointsonway[k][0]
                                if sec1:
                                    sec=sides[j[5]][5]
                                    if lastpoint not in sectorverts[sec]:
                                        addlastpoint=len(sectorverts[sec])
                                        sectorverts[sec].append(lastpoint)
                                    else:
                                        addlastpoint=sectorverts[sec].index(lastpoint)
                                    if newpoint not in sectorverts[sec]:
                                        addnewpoint=len(sectorverts[sec])
                                        sectorverts[sec].append(newpoint)
                                    else:
                                        addnewpoint=sectorverts[sec].index(newpoint)
                                    sectorlines[sec].append((addlastpoint,addnewpoint))
                                if sec2:
                                    sec=sides[j[6]][5]
                                    if lastpoint not in sectorverts[sec]:
                                        addlastpoint=len(sectorverts[sec])
                                        sectorverts[sec].append(lastpoint)
                                    else:
                                        addlastpoint=sectorverts[sec].index(lastpoint)
                                    if newpoint not in sectorverts[sec]:
                                        addnewpoint=len(sectorverts[sec])
                                        sectorverts[sec].append(newpoint)
                                    else:
                                        addnewpoint=sectorverts[sec].index(newpoint)
                                    sectorlines[sec].append((addlastpoint,addnewpoint))
                                lastpoint=newpoint
                        for sec in range(len(sectorlines)):
                            localvertices=[]
                            xmin=99999999
                            xmax=-99999999
                            ymin=99999999
                            ymax=-99999999
                            for j in sectorverts[sec]:
                                vert=verts[j]
                                if vert[0]<xmin:
                                    xmin=vert[0]
                                if vert[0]>xmax:
                                    xmax=vert[0]
                                if vert[1]<ymin:
                                    ymin=vert[1]
                                if vert[1]>ymax:
                                    ymax=vert[1]
                                localvertices.append(vert)
                            sectorboxes[sec]=[xmin,xmax,ymin,ymax]
                            if len(sectorverts[sec])>=3:
                                triangulation=triangle.triangulate({"vertices":localvertices,"segments":sectorlines[sec]},'cp')
                                hulltris=triangulation["triangles"].tolist()
                                for j in range(len(hulltris)):
                                    for k in range(3):
                                        if hulltris[j][k]<len(sectorverts[sec]):
                                            hulltris[j][k]=sectorverts[sec][hulltris[j][k]]
                                        else:
                                            verts.append(triangulation["vertices"][hulltris[j][k]])
                                            hulltris[j][k]=len(verts)-1
                                for j in range(len(hulltris)-1,-1,-1):
                                    p1=verts[hulltris[j][0]]
                                    p2=verts[hulltris[j][1]]
                                    p3=verts[hulltris[j][2]]
                                    a=math.dist(p1,p2)
                                    b=math.dist(p2,p3)
                                    c=math.dist(p1,p3)
                                    oneoversum=1/(a+b+c)
                                    midpoint=((b*p1[0]+c*p2[0]+a*p3[0])*oneoversum,(b*p1[1]+c*p2[1]+a*p3[1])*oneoversum)
                                    nearinfpoint=(99999999,midpoint[1])
                                    nearinfline=(midpoint,nearinfpoint)
                                    inters=0
                                    exactintersections={}
                                    for line in sectorlines[sec]:
                                        constraint=(sectorverts[sec][line[0]],sectorverts[sec][line[1]])
                                        vert1=verts[constraint[0]]
                                        vert2=verts[constraint[1]]
                                        exactintersect=False
                                        if constraint[0] in exactintersections:
                                            exactintersect=True
                                            orient1=exactintersections[constraint[0]]
                                            orient2=orientation(midpoint,vert1,vert2)
                                            if orient1!=0 and orient2!=0 and orient1!=orient2:
                                                inters+=1
                                        if constraint[1] in exactintersections:
                                            exactintersect=True
                                            orient1=exactintersections[constraint[1]]
                                            orient2=orientation(midpoint,vert2,vert1)
                                            if orient1!=0 and orient2!=0 and orient1!=orient2:
                                                inters+=1
                                        if not exactintersect:
                                            if lineIntersection((vert1,vert2),nearinfline):
                                                if orientation(midpoint,vert1,nearinfpoint)==0:
                                                    exactintersections[constraint[0]]=orientation(midpoint,vert1,vert2)
                                                    exactintersect=True
                                                if orientation(midpoint,vert2,nearinfpoint)==0:
                                                    exactintersections[constraint[1]]=orientation(midpoint,vert2,vert1)
                                                    exactintersect=True
                                                if not exactintersect:
                                                    inters+=1
                                    if inters%2==0:
                                        del hulltris[j]
                                sectortris[sec]=hulltris
                        for j in things:
                            checksectors=[]
                            point=(j[0],j[2])
                            for k in range(len(sectorboxes)):
                                bbox=sectorboxes[k]
                                if onSegment((bbox[0],bbox[2]),point,(bbox[1],bbox[3])):
                                    checksectors.append(k)
                            for k in range(len(checksectors)-1):#We never need to check the last one since an object should always be inside a sector
                                sec=checksectors[k]
                                constraints=sectorlines[sec]
                                nearinfpoint=(99999999,point[1])
                                nearinfline=(point,nearinfpoint)
                                inters=0
                                exactintersections={}
                                for line in constraints:
                                    constraint=(sectorverts[sec][line[0]],sectorverts[sec][line[1]])
                                    vert1=verts[constraint[0]]
                                    vert2=verts[constraint[1]]
                                    exactintersect=False
                                    if constraint[0] in exactintersections:
                                        exactintersect=True
                                        orient1=exactintersections[constraint[0]]
                                        orient2=orientation(point,vert1,vert2)
                                        if orient1!=0 and orient2!=0 and orient1!=orient2:
                                            inters+=1
                                    if constraint[1] in exactintersections:
                                        exactintersect=True
                                        orient1=exactintersections[constraint[1]]
                                        orient2=orientation(point,vert2,vert1)
                                        if orient1!=0 and orient2!=0 and orient1!=orient2:
                                            inters+=1
                                    if not exactintersect:
                                        if lineIntersection((vert1,vert2),nearinfline):
                                            if orientation(point,vert1,nearinfpoint)==0:
                                                exactintersections[constraint[0]]=orientation(point,vert1,vert2)
                                                exactintersect=True
                                            if orientation(point,vert2,nearinfpoint)==0:
                                                exactintersections[constraint[1]]=orientation(point,vert2,vert1)
                                                exactintersect=True
                                            if not exactintersect:
                                                inters+=1
                                if inters%2==1:
                                    j[1]=sectors[checksectors[k]][0]
                                    break
                            if j[1]=='-':
                                j[1]=sectors[checksectors[-1]][0]
                        with open("Lua/Libraries/WADs/"+wadname+"/Maps/"+i[2]+".lua",'w') as mapfile:
                            mapfile.write('return {VERTEXES={')
                            dontaddcomma=True
                            for j in verts:
                                if dontaddcomma:
                                    mapfile.write("{")
                                    dontaddcomma=False
                                else:
                                    mapfile.write(",{")
                                mapfile.write(str(j[0]))
                                mapfile.write(',')
                                mapfile.write(str(j[1]))
                                mapfile.write("}")
                            mapfile.write('},LINEDEFS={')
                            dontaddcomma=True
                            for j in lines:
                                if dontaddcomma:
                                    mapfile.write("{")
                                    dontaddcomma=False
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
                            dontaddcomma=True
                            for j in sides:
                                if dontaddcomma:
                                    mapfile.write("{")
                                    dontaddcomma=False
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
                                mapfile.write('"'+j[4]+'"')
                                mapfile.write(',')
                                mapfile.write(str(j[5]))
                                mapfile.write("}")
                            mapfile.write('},SECTORS={')
                            dontaddcomma=True
                            for j in sectors:
                                if dontaddcomma:
                                    mapfile.write("{")
                                    dontaddcomma=False
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
                            dontaddcomma=True
                            for j in things:
                                if dontaddcomma:
                                    mapfile.write("{")
                                    dontaddcomma=False
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
                            dontaddcomma=True
                            for j in sectortris:
                                if dontaddcomma:
                                    mapfile.write("{")
                                    dontaddcomma=False
                                else:
                                    mapfile.write(",{")
                                dontaddcomma2=True
                                for k in j:
                                    if dontaddcomma2:
                                        mapfile.write("{")
                                        dontaddcomma2=False
                                    else:
                                        mapfile.write(",{")
                                    mapfile.write(str(k[0]+1))
                                    mapfile.write(',')
                                    mapfile.write(str(k[1]+1))
                                    mapfile.write(',')
                                    mapfile.write(str(k[2]+1))
                                    mapfile.write("}")
                                mapfile.write("}")
                            mapfile.write("}}")
            if choice==1 or choice==2:
                for i in textures:
                    print("Extracting texture "+i[0])
                    tex=Image.new("RGBA",(i[1],i[2]))
                    for j in i[3]:
                        patchimg=Image.open("Sprites/WADs/"+wadname+"/PyPatches/"+pnames[j[2]]+".png")
                        tex.alpha_composite(patchimg,(j[0],j[1]))
                    tex.save("Sprites/WADs/"+wadname+"/Textures/"+i[0]+".png","PNG")
        else:
            print("WAD not identified")
