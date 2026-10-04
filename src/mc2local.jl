function mc2local(m::Mocapdata,marker::Int)
    m2 = deepcopy(m)
    d = Matrix(mcgetmarker(m,marker).data)
    r = repeat(d,1,m.nMarkers)
    m2.data = m2.data .- r
    return m2
end
function mc2local(m::Mocapdata,marker1::Int,markers::Vector{Int})
    d = mc2frontal(m,markers[1],markers[2],"frame")
    m2 = mc2local(d,marker1)
    return m2
end
