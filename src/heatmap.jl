function heatmap(m::Mocapdata)
    r,c = size(m.data)
    fig = Figure()
    if m.type == "MoCap data"
        ndims = div(c,size(m.markerName,1))
        mlabels = repeat(m.markerName,inner=ndims)
        ax = Axis(fig[1,1],yticks =(1:c,mlabels),xlabel="Time (s)",ylabel="Marker")
    elseif m.type == "Norm data"
        ax = Axis(fig[1,1],yticks =(1:c,m.markerName))
    end
    h = heatmap!(ax,m.times.Time,1:c,Matrix(m.data))
    Colorbar(fig[1, 2], h)
    display(fig)
end
function heatmap(m::Mocapdata,dim)
    md = m.data[:,dim:3:end]
    r,c = size(md)
    fig = Figure()
    ax = Axis(fig[1,1],yticks =(1:c,m.markerName),xlabel="Time (s)",ylabel="Marker")
    h = heatmap!(ax,m.times.Time,1:c,Matrix(md))
    Colorbar(fig[1, 2], h)
    display(fig)
end
