function mcanimate(m::Mocapdata;
filename = "../animation.mp4",
azimuth=0,
elevation=0,
showconn=true,
showmnumbers=false,
showmnames=false,
showaxes=false,
backgroundcolor = :black,
figsize=(800,600),
msize=30,
mcolor=:white,
mcolormap = :Accent_8,
connwidth=1,
conncolor=:white)

fig, ax, p, X, Y, Z, txt, conn, pl = plotframe(m::Mocapdata; framenum = 1, azimuth=azimuth,elevation=elevation,showconn=showconn,showmnumbers=showmnumbers,showmnames=showmnames,showaxes=showaxes,backgroundcolor=backgroundcolor,figsize=figsize,msize=msize,mcolor=mcolor,mcolormap = mcolormap, connwidth=connwidth,conncolor=conncolor)
    N = m.nFrames
    mfreq = m.freq
    record(fig,filename,1:N;framerate=mfreq) do i
        df_obs = Observable(DataFrame(x = X[i,:], y = Y[i,:], z = Z[i,:]))
        col_1 = Observable(:x)
        col_2 = Observable(:y)
        col_3 = Observable(:z)
        data = @lift(Point{3,Float64}.($df_obs[:, $col_1], $df_obs[:, $col_2],$df_obs[:, $col_3]))
        p[1][] = data[]
        if showmnumbers || showmnames
            txt[1][] = data[]
        end
        if showconn
            if all(iszero,m.conn)
                conn = [(p[1][][i-1], p[1][][i]) for i in 2:length(p[1][])]
            else
                conn = [(p[1][][m.conn[i,1]],p[1][][m.conn[i,2]]) for i in 1:size(m.conn,1)]
            end
            pl[1][] = reinterpret(Point{3,Float64},conn)
        end
    end
end
