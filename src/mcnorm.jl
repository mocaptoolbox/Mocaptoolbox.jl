mutable struct Normdata
    type::String
    filename::String
    nFrames::Int
    nMarkers::Int
    freq::Int
    markerName::Union{String, Vector{String}}
    data::DataFrame
    meta::Vector
    times::DataFrame
    timederOrder::Int
end
function mcnorm(m::Mocapdata)::Normdata
    #SelectMarkerDF(m,mnum) = m.data[:,getMarkerInd(mnum)]
    nr = size(m.data, 1)
    n = Matrix{Float64}(undef, nr, m.nMarkers)
    X = Matrix(m.data)
    nm = m.nMarkers
    mn = m.markerName
    Threads.@threads for k in 1:nm
        n[:,k] = normdim2(SelectMarker(X,k))
    end

    if size(n,2) == 1
        data = DataFrame(n,[mn],makeunique=true)
    else
        data = DataFrame(n,mn,makeunique=true)
    end
    mt = Normdata("Norm data",m.filename,nr,nm,m.freq,mn,data,m.meta,m.times,m.timederOrder)
    return mt
end
normdim2(x) = sqrt.(sum(x.^2,dims=2))
SelectMarker(m,mnum::Int)::Matrix{Float64} = m[:,getMarkerInd(mnum)]
