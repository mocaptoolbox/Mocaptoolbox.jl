function mc2global(m::Mocapdata,marker::Mocapdata)
    m2 = deepcopy(m)
    d = Matrix(marker.data)
    r = repeat(d,1,m.nMarkers)
    m2.data = m2.data .+ r
    return m2
end
