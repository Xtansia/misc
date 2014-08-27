from PIL import Image

def left_deform(tile,mult=0.5,hinc=1.25):
    tile=tile.resize((tile.size[0],int(tile.size[1]*hinc)))
    w,h=tile.size
    img=Image.new("RGBA",(w,int(h * (1+mult))),(0,0,0,0))
    y=0
    for x in range(w):
        y+=mult
        yy=int(y)
        crp=tile.crop((x,0,x+1,h))
        img.paste(crp,(x,yy))
    return img

def right_deform(tile,mult=0.5,hinc=1.25):
    ow,oh=tile.size
    tile=tile.resize((oh,int(ow*hinc)))
    w,h=tile.size
    img=Image.new("RGBA",(w,int(h * (1+mult))),(0,0,0,0))
    y=int(w*0.5)
    for x in range(w):
        y-=mult
        yy=int(y)
        crp=tile.crop((x,0,x+1,h))
        img.paste(crp,(x,yy))
    return img

def top_deform(tile):
    w,h=tile.size
    r=left_deform(tile,1,1).rotate(90)
    w*=2
    h*=2
    return left_deform(r,0.5,1).crop((0,int(h//4),w,h))

def expand_tile(tile, dim, tilen):
    w,h = tile.size
    img = Image.new("RGBA", (dim,dim), (0,0,0,0))

    if tilen == 0: #left tile
        img.paste(tile, (dim-w,0))
    elif tilen == 1: #right tile
        img.paste(tile, (0,0))
    elif tilen == 2: #top tile
        img.paste(tile, (0,dim-h))

    return img

def even(x):
    return x % 2 == 0

def render_cube(ltile,rtile,ttile):
    lw,lh = ltile.size
    rw,rh = rtile.size
    tw,th = ttile.size

    assert lw == th and even(lw)
    assert lh == rh and even(lh)
    assert rw == tw and even(rw)
    
    tile_dim = max(lw,lh, rw,rh, tw,th)
    
    if lw != tile_dim or lh != tile_dim:
        ltile = expand_tile(ltile, tile_dim, tilen=0)
    if rw != tile_dim or rh != tile_dim:
        rtile = expand_tile(rtile, tile_dim, tilen=1)
    if tw != tile_dim or th != tile_dim:
        ttile = expand_tile(ttile, tile_dim, tilen=2)
    
    ltile=left_deform(ltile)
    rtile=right_deform(rtile)
    ttile=top_deform(ttile)
    
    img=Image.new("RGBA",(int(tile_dim*2),int(tile_dim*2.25)),(0,0,0,0))

    img.paste(ttile,(0,0),ttile)
    img.paste(ltile,(0,int(tile_dim / 2)),ltile)
    img.paste(rtile,(tile_dim,int(tile_dim / 2)),rtile)

    img=img.crop((tile_dim-lw,int((tile_dim-th)/2),tile_dim+rw,int(tile_dim + 1.25*lh)))
    
    return img

computer_pcs = ["computerFrontOn.png", "computerSide.png", "computerTop.png"]
modem_pcs = ["wirelessModemLeftOn.png", "wirelessModemFace.png", "wirelessModemTopOn.png"]

tile_scale = 16 # 16px tile -> 256px tile => ~512px final image

for x in range(3):
    img = Image.open(computer_pcs[x])
    w,h = img.size
    computer_pcs[x] = img.resize((int(w*tile_scale), int(h*tile_scale)))
    
    img = Image.open(modem_pcs[x])
    w,h = img.size
    modem_pcs[x] = img.resize((int(w*tile_scale), int(h*tile_scale)))

modem = render_cube(modem_pcs[0], modem_pcs[1], modem_pcs[2])
computer = render_cube(computer_pcs[0], computer_pcs[1], computer_pcs[2])

w,h = computer.size
pixw = w/32

img = Image.new("RGBA", (h,h), (0,0,0,0))
img.paste(computer, (pixw*2, 0), computer)
img.paste(modem, (pixw*20, pixw/2 * 23), modem)
img.save("out.png")
