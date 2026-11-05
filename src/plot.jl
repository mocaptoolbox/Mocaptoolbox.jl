function Makie.plot(m::Union{Mocapdata,Normdata};reorder=true)
    fig = Figure()
    ax = Axis(fig[1,1],xlabel="Time (s)",ylabel="Feature value")
    for k in 1:size(m.data,2)
        lines!(ax,m.times.Time/m.freq,m.data[:,k])
    end
    return fig
end
function Makie.plot(m::Mocapdata,dim)
    fig = Figure()
    ax = Axis(fig[1,1],xlabel="Time (s)",ylabel="Feature value")
    for k in dim:3:size(m.data,2)
        lines!(ax,m.times.Time/m.freq,m.data[:,k])
    end
    return fig
end
function Makie.plot(m::Orderpar)
    f = Figure()
    ax = PolarAxis(f[1, 1], title = m.mname)
    s = scatter!(m.directional_at_beats,collect(m.beats), color = :orange)
    return f,ax,s
end
function Makie.plot(d::Sumdiags;bpm=nothing)
    f = Figure()
    peaklag = d.peaklag
    if bpm == nothing
        x = d.lags
        xlabel = "τ (s)"
    else
        x = Mocaptoolbox.lags2beatlag(d.lags,bpm)
        peaklag = Mocaptoolbox.lags2beatlag(peaklag,bpm)
        xlabel = "Beat τ (s)"
    end
    peaklabel = map(x-> Printf.@sprintf("%g", x),[peaklag,d.peakval])
    ax = Axis(f[1, 1], title = "Sum across diagonals of XYᵀ",xlabel=xlabel)
    s = lines!(x,d.sumdiags, color = :orange)
    annotation!(ax,d.peaklag,d.peakval,text = "($(peaklabel[1]),$(peaklabel[2]))")
    return f
end
function Makie.plot(d::Vector{Sumdiags};level=.95,bpm=nothing)
    f = Figure()
    xm = hcat([x.sumdiags for x in d]...)
    meansumdiags = mean(xm,dims=2)
    if bpm == nothing
        x = d[1].lags
        xlabel = "τ (s)"
    else
        x = lags2beatlag(d[1].lags,bpm)
        xlabel = "Beat τ (s)"
    end
    ax = Axis(f[1, 1], title = "Sum across diagonals of XYᵀ (mean across dyads)",xlabel=xlabel)
    y = meansumdiags[:]
    s = lines!(x,y, color = :orange)
    ci = Mocaptoolbox.get_ci.(eachrow(xm),level=level)
    lower,upper = eachrow(hcat(ci...))
    band!(x,lower,upper;color=(:violet, 0.2))
    return f
end
function get_ci(data;level=.95)
    n = length(data)
    m = mean(data)
    s = std(data)
    se = s / sqrt(n)
    level = level
    α = 1 - level
    t_crit = quantile(TDist(n - 1), 1 - α / 2)
    ci_lower = m - t_crit * se
    ci_upper = m + t_crit * se
    return [ci_lower,ci_upper]
end
lags2beatlag(lags,bpm) = lags ./ (60/bpm)
