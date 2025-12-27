function heatmap(m::Mocapdata;reorder=true)
    x = Matrix(m.data)
    if reorder == true
        x = Mocaptoolbox.reorderdims(x)
    end
    r,c = size(m.data)
    fig = Figure()
    ndims = div(c,size(m.markerName,1))
    mlabels = repeat(m.markerName,inner=ndims)
    ax = Axis(fig[1,1],yticks =(1:c,mlabels),xlabel="Time (s)",ylabel="Marker")
    h = heatmap!(ax,m.times.Time,1:c,x)
    Colorbar(fig[1, 2], h)
    display(fig)
end
function heatmap(m::Normdata;reorder=true)
    x = Matrix(m.data)
    if reorder == true && m.type == "Norm data"
        display("No reordering with norm data")
    end
    r,c = size(m.data)
    fig = Figure()
    ax = Axis(fig[1,1],yticks =(1:c,m.markerName))
    h = heatmap!(ax,m.times.Time,1:c,x)
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
