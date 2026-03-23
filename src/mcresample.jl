function mcresample(m::Union{Mocapdata,Normdata}, newfreq::Int64)
d1 = m.data
    t1 = collect(0:(size(d1,1)-1))/m.freq
    t2 = 0:(1/newfreq):t1[end]
    ser = FastInterpolations.Series(Matrix(d1)) # interpolate so as to get the unwrapped phase difference at each beat
    itp = cubic_interp(t1,ser)
    interpmat = hcat(itp(t2)...)
    res = deepcopy(m)
    res.data = DataFrame(interpmat,names(m.data))
    res.freq = newfreq
    res.times = DataFrame(Frame=1:size(t2,1), Time=collect(t2))
    res.nFrames = size(res.data,1)
    return res
end
