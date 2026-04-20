function mcresample(m::Union{Mocapdata,Normdata}, newfreq::Int)
    d1 = Matrix(m.data)
    n = size(d1,1)
    t1 = (0:n-1)./ m.freq
    t2 = 0:(1/newfreq):t1[end]
    ser = FastInterpolations.Series(d1)
    itp = cubic_interp(t1,ser)
    interpmat = Matrix{eltype(d1)}(undef, length(t2), size(d1, 2))
    Threads.@threads for i in eachindex(t2)
        @inbounds interpmat[i, :] = itp(t2[i])
    end
    res = deepcopy(m)
    res.data = DataFrame(interpmat,names(m.data))
    res.freq = newfreq
    res.times = DataFrame(Frame=1:size(t2,1), Time=collect(t2))
    res.nFrames = size(res.data,1)
    return res
end
