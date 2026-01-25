function mcgetmarker(m::Mocapdata,mnum::Int)
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mnum)
    g.markerName = [getMarkerNameFromMarkerNum(m,mnum)]
    g.nMarkers = length(mnum)
    g.conn = updateconns(m.conn,mnum)
    return g
end
function mcgetmarker(m::Mocapdata, mnum::Union{Vector{Int64},UnitRange{Int64}})
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mnum)
    g.markerName = getMarkerNameFromMarkerNum(m,mnum)
    g.nMarkers = length(mnum)
    g.conn = updateconns(m.conn,mnum)
    return g
end
function mcgetmarker(m::Normdata, mnum::Union{Vector{Int64},UnitRange{Int64}})
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mnum)
    g.markerName = getMarkerNameFromMarkerNum(m,mnum)
    g.nMarkers = length(mnum)
    return g
end
function mcgetmarker(m::Mocapdata,mname::String)
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mname)
    g.markerName = [mname]
    g.nMarkers = length([mname])
    g.conn = updateconns(m.conn,mname)
    return g
end
function mcgetmarker(m::Normdata,mname::String)
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mname)
    g.markerName = [mname]
    g.nMarkers = length([mname])
    return g
end
function mcgetmarker(m::Mocapdata,mname::Vector{String})
    if length(unique(m.markerName)) != length(m.markerName)
        error("Marker names are not unique")
    end
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mname)
    g.markerName = mname
    g.nMarkers = length(mname)
    mnum = getMarkerNameInd(m,mname)
    g.conn = updateconns(m.conn,mnum)
    return g
end
function mcgetmarker(m::Normdata,mname::Vector{String})
    if length(unique(m.markerName)) != length(m.markerName)
        error("Marker names are not unique")
    end
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mname)
    g.markerName = mname
    g.nMarkers = length(mname)
    mnum = getMarkerNameInd(m,mname)
    return g
end
function mcgetmarker(m::Normdata,mnum::Int)
    g = deepcopy(m)
    g.data = m.data[:,[mnum]]
    g.markerName = [getMarkerNameFromMarkerNum(m,mnum)]
    g.nMarkers = length(mnum)
    return g
end
getMarkerInd(i) = (3i-2):(3i)
getMarkerNameInd(m,mname::String) = findfirst(==(mname), m.markerName)
getMarkerNameInd(m,mname::Vector{String}) = convert(Vector{Int},indexin(mname,m.markerName))
SelectMarkerDF(m::Normdata,mname::String) = m.data[:,[getMarkerNameInd(m,mname)]]
SelectMarkerDF(m::Normdata,mname::Vector{String}) = m.data[:,getMarkerNameInd(m,mname)]
getMarkerNameFromMarkerNum(m,mnum) = m.markerName[mnum]
SelectMarkerDF(m::Mocapdata,mnum::Int64) = m.data[:,getMarkerInd(mnum)]
SelectMarkerDF(m::Mocapdata, mnum::Vector{Int64}) = m.data[:,vcat(getMarkerInd.(vec(mnum))...)]
SelectMarkerDF(m::Mocapdata, mnum::UnitRange{Int64}) = m.data[:,vcat(getMarkerInd.(collect(mnum))...)]
SelectMarkerDF(m::Mocapdata,mname::String) = m.data[:,getMarkerInd(getMarkerNameInd(m,mname))]
SelectMarkerDF(m::Mocapdata,mname::Vector{String}) = m.data[:,vcat(getMarkerInd.(getMarkerNameInd(m,mname))...)]
SelectMarkerDF(m::Normdata, mnum::Vector{Int64}) = m.data[:,vcat(mnum...)]
SelectMarkerDF(m::Normdata, mnum::UnitRange{Int64}) = m.data[:,collect(mnum)]
function updateconns(oldconn,mnum_mname::Union{Int,String})
    conn = deepcopy(oldconn)
    conn = Matrix{Int64}(undef, 0, 0)
end
function updateconns(oldconn,mnum::Union{Vector{Int64},UnitRange{Int64}})
    conn = deepcopy(oldconn)
    conn = conn[vec(all(reduce(.|,[conn .== x for x in mnum]),dims=2)),:]
    connorig=deepcopy(conn)
    for k = 1:length(unique(connorig))
        conn[findall(connorig .== minimum(connorig))] .= k
        connorig[findall(connorig .== minimum(connorig))] .= typemax(Int)
    end
    return conn
end
