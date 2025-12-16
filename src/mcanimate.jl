using Infiltrator
function mcanimate(m::mocapdata; framerate = m.freq, filename = "animation.mp4",azimuth=0,elevation=0)
    data = Matrix(m.data)
    X = data[:, 1:3:end]
    Y = data[:, 2:3:end]
    Z = data[:, 3:3:end]
    fig = Figure()
    xlim=extrema(filter(!isnan,X))
    ylim=extrema(filter(!isnan,Y))
    zlim=extrema(filter(!isnan,Z))
    ax = Axis3(fig[1, 1],aspect=:data,limits = (xlim[1], xlim[2], ylim[1], ylim[2], zlim[1], zlim[2]))
    ax.azimuth = azimuth
    ax.elevation = elevation
    hidespines!(ax)
    hidedecorations!(ax)

    p = meshscatter!(ax,X[1,:],Y[1,:],Z[1,:],markersize=20)

    @infiltrate
    conn = [(p[1][][i-1], p[1][][i]) for i in 2:length(p[1][])]
    pl = linesegments!(ax, conn,color=:blue)

    N = m.nFrames
    record(fig,filename,1:N;framerate=framerate) do i

        df_obs = Observable(DataFrame(x = X[i,:], y = Y[i,:], z = Z[i,:]))
        col_1 = Observable(:x)
        col_2 = Observable(:y)
        col_3 = Observable(:z)
        data = @lift(Point{3,Float64}.($df_obs[:, $col_1], $df_obs[:, $col_2],$df_obs[:, $col_3]))
        p[1][] = data[]
        conn = [(p[1][][i-1], p[1][][i]) for i in 2:length(p[1][])]
        pl[1][]=reinterpret(Point{3,Float64},conn)
    end
end
