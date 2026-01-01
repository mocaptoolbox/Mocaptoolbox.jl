function mcgetmarker(m::Mocapdata,mnum::Int)
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mnum)
    g.markerName = [getMarkerNameFromMarkerNum(m,mnum)]
    g.nMarkers = length(mnum)
    return g
end
function mcgetmarker(m::Union{Mocapdata,Normdata}, mnum::Union{Vector{Int64},UnitRange{Int64}})
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mnum)
    g.markerName = getMarkerNameFromMarkerNum(m,mnum)
    g.nMarkers = length(mnum)
    return g
end
function mcgetmarker(m::Union{Mocapdata,Normdata},mname::String)
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mname)
    g.markerName = [mname]
    g.nMarkers = length([mname])
    return g
end
function mcgetmarker(m::Union{Mocapdata,Normdata},mname::Vector{String})
    if length(unique(m.markerName)) != length(m.markerName)
        error("Marker names are not unique")
    end
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mname)
    g.markerName = mname
    g.nMarkers = length(mname)
    return g
end
function mcgetmarker(m::Normdata,mnum::Int)
    g = deepcopy(m)
    g.data = m.data[:,mnum]
    g.markerName = [getMarkerNameFromMarkerNum(m,mnum)]
    g.nMarkers = length(mnum)
    return g
end
getMarkerInd(i) = (3i-2):(3i)
getMarkerNameInd(m,mname::String) = findfirst(==(mname), m.markerName)
getMarkerNameInd(m,mname::Vector{String}) = indexin(mname,m.markerName)
SelectMarkerDF(m::Normdata,mname) = m.data[:,getMarkerNameInd(m,mname)]
getMarkerNameFromMarkerNum(m,mnum) = m.markerName[mnum]
SelectMarkerDF(m::Mocapdata,mnum::Int) = m.data[:,getMarkerInd(mnum)]
SelectMarkerDF(m::Mocapdata, mnum::Vector{Int64}) = m.data[:,vcat(getMarkerInd.(vec(mnum))...)]
SelectMarkerDF(m::Mocapdata, mnum::UnitRange{Int64}) = m.data[:,vcat(getMarkerInd.(collect(mnum))...)]
SelectMarkerDF(m::Mocapdata,mname::String) = m.data[:,getMarkerInd(getMarkerNameInd(m,mname))]
SelectMarkerDF(m::Mocapdata,mname::Vector{String}) = m.data[:,vcat(getMarkerInd.(getMarkerNameInd(m,mname))...)]
SelectMarkerDF(m::Normdata, mnum::Vector{Int64}) = m.data[:,vcat(mnum...)]
SelectMarkerDF(m::Normdata, mnum::UnitRange{Int64}) = m.data[:,collect(mnum)]
