function mc2local(m::Mocapdata,marker)
    m2 = deepcopy(m)
    d = Matrix(mcgetmarker(m,marker).data)
    r = repeat(d,1,m.nMarkers)
    m2.data = m2.data .- r
    return m2
end
