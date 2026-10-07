#!/usr/bin/env bash

trap 'tput cnorm; clear; exit 0' INT TERM
tput civis
clear

angle=0
while true; do
    cols=$(tput cols)
    lines=$(tput lines)

    frame=$(awk -v cols="$cols" -v lines="$lines" -v angle="$angle" '
    BEGIN {
        pi = atan2(0,-1)
        cx = cols/2
        cy = lines/2
        Rw = cols/5
        Rh = lines/2.5
        R  = (Rw < Rh ? Rw : Rh)
        if (R < 8) R = 8
        ramp = " .:-=+*#%@"
        nramp = length(ramp)

        for (y=0; y<lines; y++)
            for (x=0; x<cols; x++) { buf[y,x]=" "; zbuf[y,x]=-999 }

        ca=cos(angle); sa=sin(angle)
        lx=0.4; ly=0.6; lz=-1
        ll=sqrt(lx*lx+ly*ly+lz*lz); lx/=ll; ly/=ll; lz/=ll

        tilt = 0.45
        lean = -0.35
        ctx=cos(tilt); stx=sin(tilt)
        clz=cos(lean); slz=sin(lean)

        for (vi=0; vi<=60; vi++) {
            v = vi*pi/60
            t = cos(v)
            s = sin(v)
            rad = s*(1 + 0.10*cos(2*v))
            if (rad<0) rad=0
            stemdip  = (t>0.88) ? ((t-0.88)/0.12)*0.30 : 0
            basedip  = (t<-0.88) ? ((-0.88-t)/0.12)*0.22 : 0

            for (ui=0; ui<120; ui++) {
                u = ui*2*pi/120
                cu=cos(u); su=sin(u)

                ox = rad*cu
                oy = t*0.95 - stemdip + basedip
                oz = rad*su

                nlen = sqrt(ox*ox+oy*oy+oz*oz); if (nlen==0) nlen=1
                nx=ox/nlen; ny=oy/nlen; nz=oz/nlen

                lx1 = ox*clz - oy*slz
                ly1 = ox*slz + oy*clz
                lz1 = oz
                tx1 = lx1
                ty1 = ly1*ctx - lz1*stx
                tz1 = ly1*stx + lz1*ctx

                nlx1 = nx*clz - ny*slz
                nly1 = nx*slz + ny*clz
                nlz1 = nz
                ntx1 = nlx1
                nty1 = nly1*ctx - nlz1*stx
                ntz1 = nly1*stx + nlz1*ctx

                rx = tx1*ca - tz1*sa
                rz = tx1*sa + tz1*ca
                ry = ty1

                rnx = ntx1*ca - ntz1*sa
                rnz = ntx1*sa + ntz1*ca
                rny = nty1

                px = int(cx + rx*R)
                py = int(cy - ry*R*0.55)

                if (px>=0 && px<cols && py>=0 && py<lines) {
                    if (rz > zbuf[py,px]) {
                        zbuf[py,px] = rz
                        lum = rnx*lx + rny*ly + rnz*lz
                        if (lum<0) lum=0
                        ambient = 0.22
                        lum = ambient + (1-ambient)*lum
                        idx = int(lum*(nramp-1))
                        if (idx>=nramp) idx=nramp-1
                        buf[py,px] = substr(ramp, idx+1, 1)
                    }
                }
            }
        }

        for (si=0; si<6; si++) {
            sox = 0
            soy = 1.05 + si*0.12
            soz = 0
            lx1 = sox*clz - soy*slz
            ly1 = sox*slz + soy*clz
            lz1 = soz
            tx1 = lx1
            ty1 = ly1*ctx - lz1*stx
            tz1 = ly1*stx + lz1*ctx
            rx = tx1*ca - tz1*sa
            rz = tx1*sa + tz1*ca
            ry = ty1
            px = int(cx + rx*R)
            py = int(cy - ry*R*0.55)
            if (px>=0 && px<cols && py>=0 && py<lines && rz>zbuf[py,px]) buf[py,px]="|"
        }

        out = ""
        for (y=0; y<lines; y++) {
            line=""
            for (x=0; x<cols; x++) line = line buf[y,x]
            out = out line "\n"
        }
        printf "%s", out
    }')

    tput cup 0 0
    printf "%s" "$frame"
    angle=$(awk -v a="$angle" 'BEGIN{printf "%f", a+0.12}')
    sleep 0.04
done
