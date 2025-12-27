function plot(m::Union{Mocapdata,Normdata};reorder=true)
    fig = Figure()
    ax = Axis(fig[1,1],xlabel="Time (s)",ylabel="Feature value")
    for k in 1:size(m.data,2)
        lines!(ax,m.times.Time,m.data[:,k])
    end
    display(fig)
end
function plot(m::Mocapdata,dim)
    fig = Figure()
    ax = Axis(fig[1,1],xlabel="Time (s)",ylabel="Feature value")
    for k in dim:3:size(m.data,2)
        lines!(ax,m.times.Time,m.data[:,k])
    end
    display(fig)
end
