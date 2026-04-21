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
mcolormap = :Accent_7,
connwidth=2,
conncolor=:white,
viewmode=:fitzoom,
xlim=(NaN,NaN),
ylim=(NaN,NaN),
zlim=(NaN,NaN))

    fig, ax::Axis3, p::MeshScatter{Tuple{Vector{Point{3, Float64}}}}, X, Y, Z, txt::Union{Nothing,Makie.Text{Tuple{Vector{Point{3, Float64}}}}}, conn::Vector{Tuple{Point{3, Float64}, Point{3, Float64}}}, pl::Union{Nothing,LineSegments{Tuple{Base.ReinterpretArray{Point{3, Float64}, 1, Tuple{Point{3, Float64}, Point{3, Float64}}, Vector{Tuple{Point{3, Float64}, Point{3, Float64}}}, false}}}} = plotframe(m::Mocapdata; framenum = framenum, azimuth=azimuth,elevation=elevation,showconn=showconn,showmnumbers=showmnumbers,showmnames=showmnames,showaxes=showaxes,backgroundcolor=backgroundcolor,figsize=figsize,msize=msize,mcolor=mcolor,mcolormap = mcolormap, connwidth=connwidth, conncolor=conncolor,viewmode=viewmode,xlim=xlim,ylim=ylim,zlim=zlim)
    return fig, ax, p, X, Y, Z, txt, conn, pl
end
function plotframe(m::Mocapdata; framenum = 1,azimuth=0,elevation=0,showconn=true,showmnumbers=false,showmnames=false,showaxes=true,backgroundcolor=:white,figsize=(800, 600),msize=msize,mcolor=mcolor,mcolormap=colormap,connwidth=connwidth,conncolor=conncolor,viewmode=viewmode,xlim=(NaN,NaN),ylim=(NaN,NaN),zlim=(NaN,NaN))
    data = Matrix(m.data)
    X = data[:, 1:3:end]
    Y = data[:, 2:3:end]
    Z = data[:, 3:3:end]
    fig = Figure(size=figsize,backgroundcolor=backgroundcolor)
    any(isnan.(xlim)) ? xlim=extrema(filter(!isnan,X)) : Nothing
    any(isnan.(ylim)) ? ylim=extrema(filter(!isnan,Y)) : Nothing
    any(isnan.(zlim)) ? zlim=extrema(filter(!isnan,Z)) : Nothing
    f = fig[1, 1]
    ax = Axis3(f,aspect=:data,limits = (xlim[1], xlim[2], ylim[1], ylim[2], zlim[1], zlim[2]),viewmode=viewmode)
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
        pl = nothing
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
