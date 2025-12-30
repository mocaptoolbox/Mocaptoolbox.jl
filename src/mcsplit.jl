"""
Split data horizontally into n parts.
"""
function mcsplit(m::Mocapdata,parts=2::Int)
    r,c = size(m.data)
    r2,_ = size(m.conn)
    if mod(c,parts) != 0
        error("Cannot split data into even number of parts")
    end
    ndimspart = div(c,parts)
    nmarkerspart = div(m.nMarkers,parts)
    nconnpart = div(r2,parts)
    v = [zeros(r, ndimspart) for i in 1:parts]
    d = Vector{Mocapdata}(undef,parts)
    winfun(x,k) = collect((1:x).+x*(k-1))
    for k = 1:parts
        dims = winfun(ndimspart,k)
        dimsmarker = winfun(nmarkerspart,k)
        dimsconn = winfun(nconnpart,k)
        v[k] = Matrix(m.data[:,dims])
        d[k] = deepcopy(m)
        d[k].data = DataFrame(v[k],names(m.data)[dims])
        d[k].conn = m.conn[dimsconn,:]
        d[k].markerName = m.markerName[dimsmarker]
        d[k].nMarkers = div(m.nMarkers,nmarkerspart)
    end
    return d
end
function mcsplit(m::Normdata,parts=2::Int)
    r,c = size(m.data)
    if mod(c,parts) != 0
        error("Cannot split data into even number of parts")
    end
    ndimspart = div(c,parts)
    v = [zeros(r, ndimspart) for i in 1:parts]
    d = Vector{Normdata}(undef,parts)
    winfun(x,k) = collect((1:x).+x*(k-1))
    for k = 1:parts
        dims = winfun(ndimspart,k)
        v[k] = Matrix(m.data[:,dims])
        d[k] = deepcopy(m)
        d[k].data = DataFrame(v[k],names(m.data)[dims])
        d[k].markerName = m.markerName[dims]
        d[k].nMarkers = div(m.nMarkers,ndimspart)
    end
    return d
end
