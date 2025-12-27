function mcgetmarker(m::Mocapdata,mnum::Int)
    SelectMarkerDF(m,mnum) = m.data[:,getMarkerInd(mnum)]
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mnum)
    getMarkerNameFromMarkerNum(m,mnum) = [m.markerName[mnum]]
    g.markerName = getMarkerNameFromMarkerNum(m,mnum)
    g.nMarkers = length(mnum)
    return g
end
function mcgetmarker(m::Mocapdata, mnum::Vector{Int64})
    SelectMarkerDF(m,mnum) = m.data[:,vcat(getMarkerInd.(vec(mnum))...)]
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mnum)
    getMarkerNameFromMarkerNum(m,mnum) = m.markerName[mnum]
    g.markerName = getMarkerNameFromMarkerNum(m,mnum)
    g.nMarkers = length(mnum)
    return g
end
function mcgetmarker(m::Mocapdata, mnum::UnitRange{Int64})
    SelectMarkerDF(m,mnum) = m.data[:,vcat(getMarkerInd.(collect(mnum))...)]
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mnum)
    getMarkerNameFromMarkerNum(m,mnum) = m.markerName[mnum]
    g.markerName = getMarkerNameFromMarkerNum(m,mnum)
    g.nMarkers = length(mnum)
    return g
end
function mcgetmarker(m::Mocapdata,mname::String)
    getMarkerNameInd(m,mname) = findall(m.markerName .== mname)
    SelectMarkerDF(m,mname) = m.data[:,getMarkerInd(getMarkerNameInd(m,mname))]
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mname)
    g.markerName = [mname]
    g.nMarkers = length([mname])
    return g
end
function mcgetmarker(m::Mocapdata,mname::Vector{String})
    if length(unique(m.markerName)) != length(m.markerName)
        error("Marker names in mocap struct are not unique")
    end
    getMarkerNameInd(m,mname) = indexin(mname,m.markerName)
    SelectMarkerDF(m,mname) = m.data[:,vcat(getMarkerInd.(getMarkerNameInd(m,mname))...)]
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mname)
    g.markerName = mname
    g.nMarkers = length(mname)
    return g
end
function mcgetmarker(m::Normdata,mnum::Int)
    g = deepcopy(m)
    g.data = m.data[:,mnum]
    getMarkerNameFromMarkerNum(m,mnum) = [m.markerName[mnum]]
    g.markerName = getMarkerNameFromMarkerNum(m,mnum)
    g.nMarkers = length(mnum)
    return g
end
function mcgetmarker(m::Normdata, mnum::Vector{Int64})
    SelectMarkerDF(m,mnum) = m.data[:,vcat(mnum...)]
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mnum)
    getMarkerNameFromMarkerNum(m,mnum) = m.markerName[mnum]
    g.markerName = getMarkerNameFromMarkerNum(m,mnum)
    g.nMarkers = length(mnum)
    return g
end
function mcgetmarker(m::Normdata, mnum::UnitRange{Int64})
    SelectMarkerDF(m,mnum) = m.data[:,collect(mnum)]
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mnum)
    getMarkerNameFromMarkerNum(m,mnum) = m.markerName[mnum]
    g.markerName = getMarkerNameFromMarkerNum(m,mnum)
    g.nMarkers = length(mnum)
    return g
end
function mcgetmarker(m::Normdata,mname::String)
    getMarkerNameInd(m,mname) = findall(m.markerName .== mname)
    SelectMarkerDF(m,mname) = m.data[:,getMarkerNameInd(m,mname)]
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mname)
    g.markerName = [mname]
    g.nMarkers = length([mname])
    return g
end
function mcgetmarker(m::Normdata,mname::Vector{String})
    if length(unique(m.markerName)) != length(m.markerName)
        error("Marker names are not unique")
    end
    getMarkerNameInd(m,mname) = indexin(mname,m.markerName)
    SelectMarkerDF(m,mname) = m.data[:,getMarkerNameInd(m,mname)]
    g = deepcopy(m)
    g.data = SelectMarkerDF(m,mname)
    g.markerName = mname
    g.nMarkers = length(mname)
    return g
end
getMarkerInd(markernameind) = 3*(markernameind.-1) .+ collect(1:3)
