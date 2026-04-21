function Makie.hist(m::Mocapdata;reorder=true,fillgaps=true)
    if fillgaps==true
        m = mcfillgaps(m)
    end
    x = Matrix(m.data)
    if reorder == true && m.type == "MoCap data"
        x = Mocaptoolbox.reorderdims(x)
    end
    r,c = size(x)
    fig = Figure()
    ndims = div(c,size(m.markerName,1))
    if reorder == true && m.type == "MoCap data"
        mlabels = repeat(m.markerName,outer=ndims)
    else
        mlabels = repeat(m.markerName,inner=ndims)
    end
    ax = Axis(fig[1,1],xticks =(1:c,mlabels),ylabel="Feature value",xticklabelrotation=π/2)
    for i = 1:c
        hist!(ax, x[:,i], scale_to=-0.6, offset=i, direction=:x)
    end
    return fig
end
function Makie.hist(m::Normdata;reorder=true,fillgaps=true)
    if fillgaps==true
        m = mcfillgaps(m)
    end
    x = Matrix(m.data)
    if reorder == true && m.type == "MoCap data"
        x = Mocaptoolbox.reorderdims(x)
    end
    r,c = size(x)
    fig = Figure()
    ax = Axis(fig[1, 1],xticks = (1:c,m.markerName),xticklabelrotation=π/2)
    for i = 1:c
        hist!(ax, x[:,i], scale_to=-0.6, offset=i, direction=:x)
    end
    return fig
end
function Makie.hist(m::Mocapdata,dim;fillgaps=true)
    if fillgaps==true
        m = mcfillgaps(m)
    end
    fig = Figure()
    x = Matrix(m.data)[:,dim:3:end]
    r,c = size(x)
    ax = Axis(fig[1, 1],xticks =(1:c,m.markerName),ylabel="Feature value",xticklabelrotation=π/2)
    for i = 1:c
        hist!(ax, x[:,i], scale_to=-0.6, offset=i, direction=:x)
    end
    return fig
end
function reorderdims(x)
    x = [x[:,1:3:end] x[:,2:3:end] x[:,3:3:end]]
end
