function mcresample(m::Mocapdata, newfreq)
d1 = m.data
    t1 = collect(0:(size(d1,1)-1))/m.freq
    t2 = 0:(1/newfreq):t1[end]
    interpvec = Vector{Vector{Float64}}(undef,size(d1,2))
    for k = 1:size(d1,2)
        interp = LinearInterpolation(d1[:,k],t1)
        interpvec[k] = interp(t2)
    end
    interpmat = hcat(interpvec...)
    res = deepcopy(m)
    res.data = DataFrame(interpmat,names(m.data))
    res.freq = newfreq
    res.times = DataFrame(Frame=1:size(t2,1), Time=collect(t2))
    res.nFrames = size(res.data,1)
    return res
end
