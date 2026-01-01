function mcplotframe(m::Mocapdata;
framenum=1,
azimuth=0,
elevation=0,
showconn=true,
showmnumbers=false,
showmnames=false,
showaxes=false, # axes are black
backgroundcolor = :black,
figsize=(800,600),
msize=30,
mcolor=:white,
mcolormap = :Accent_8,
connwidth=2,
conncolor=:white)

    fig, ax, p, X, Y, Z, txt, conn, pl = plotframe(m::Mocapdata; framenum = framenum, azimuth=azimuth,elevation=elevation,showconn=showconn,showmnumbers=showmnumbers,showmnames=showmnames,showaxes=showaxes,backgroundcolor=backgroundcolor,figsize=figsize,msize=msize,mcolor=mcolor,mcolormap = mcolormap, connwidth=connwidth, conncolor=conncolor)
    display(fig)
    return fig, ax, p, X, Y, Z, txt, conn, pl
end
function plotframe(m::Mocapdata; framenum = 1,azimuth=0,elevation=0,showconn=true,showmnumbers=false,showmnames=false,showaxes=true,backgroundcolor=:white,figsize=(800, 600),msize=msize,mcolor=mcolor,mcolormap=colormap,connwidth=connwidth,conncolor=conncolor)
    data = Matrix(m.data)
    X = data[:, 1:3:end]
    Y = data[:, 2:3:end]
    Z = data[:, 3:3:end]
    fig = Figure(size=figsize,backgroundcolor=backgroundcolor)
    xlim=extrema(filter(!isnan,X))
    ylim=extrema(filter(!isnan,Y))
    zlim=extrema(filter(!isnan,Z))
    ax = Axis3(fig[1, 1],aspect=:data,limits = (xlim[1], xlim[2], ylim[1], ylim[2], zlim[1], zlim[2]))
    ax.azimuth = azimuth
    ax.elevation = elevation
    ax.backgroundcolor = backgroundcolor
    hidespines!(ax)
    if showaxes == false
        hidedecorations!(ax)
    end
    p = meshscatter!(ax,X[framenum,:],Y[framenum,:],Z[framenum,:],markersize=msize,color=mcolor,colormap=mcolormap,clip_planes=Plane3f[])
    if showconn == true
        if all(iszero,m.conn)
            conn = [(p[1][][i-1], p[1][][i]) for i in 2:length(p[1][])]
        else
            conn = [(p[1][][m.conn[i,1]],p[1][][m.conn[i,2]]) for i in 1:size(m.conn,1)]
        end
        pl = linesegments!(ax, conn,color=conncolor,linewidth=connwidth)
    else
        conn = []
        pl = []
    end
    txt = nothing
    if showmnumbers && !showmnames
        txt = text!(ax,X[framenum,:],Y[framenum,:],Z[framenum,:],text = string.(1:length(m.markerName)),color=:white) # text as numbers
    elseif showmnames && !showmnumbers
        txt = text!(ax,X[framenum,:],Y[framenum,:],Z[framenum,:],text = m.markerName,color=:white) # text as marker names
    elseif showmnumbers && showmnames
        txt = text!(ax,X[framenum,:],Y[framenum,:],Z[framenum,:],text = string.(1:length(m.markerName)) .* " " .* m.markerName) # text as marker names
    end
    return fig, ax, p, X, Y, Z, txt, conn, pl
end
makecolorvector(m,nsubjects) = repeat(1:nsubjects,inner=m.nMarkers)
