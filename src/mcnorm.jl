function mcnorm(m::Mocapdata)
    SelectMarkerDF(m,mnum) = m.data[:,getMarkerInd(mnum)]

    n = Matrix{Float64}(undef, size(m.data, 1), m.nMarkers)
    for k in 1:m.nMarkers
        n[:,k] = normdim2(Matrix(SelectMarkerDF(m,k)))
    end
    res = deepcopy(m)
    res.data = DataFrame(n,m.markerName,makeunique=true)
    res.type = "Norm data"
    return res
end
normdim2(x) = sqrt.(sum(x.^2,dims=2))
