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
function mcnorm(m::Mocapdata)
    SelectMarkerDF(m,mnum) = m.data[:,getMarkerInd(mnum)]

    n = Matrix{Float64}(undef, size(m.data, 1), m.nMarkers)
    for k in 1:m.nMarkers
        n[:,k] = normdim2(Matrix(SelectMarkerDF(m,k)))
    end
    data = DataFrame(n,m.markerName,makeunique=true)
    mt = Normdata("Norm data",m.filename,m.nFrames,m.nMarkers,m.freq,m.markerName,data,m.meta,m.times,m.timederOrder)
    return mt
end
normdim2(x) = sqrt.(sum(x.^2,dims=2))
