function mcvcat(m::Mocapdata...)
    m2 = deepcopy(m[1])
    map(x->x.data,m)
    m2.data = vcat(map(x->x.data,m)...)
    m2.nFrames = size(m2.data,1)
    return m2
end
