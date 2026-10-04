"""
Use a mocapstruct containing one marker to bring local coordinate system data back to a global coordinate system.
"""
function mc2global(m::Mocapdata,marker::Mocapdata)
    m2 = deepcopy(m)
    d = Matrix(marker.data)
    r = repeat(d,1,m.nMarkers)
    m2.data = m2.data .+ r
    return m2
end
