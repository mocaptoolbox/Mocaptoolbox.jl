""" `mcrowmean` computes, for each component, the mean across all rows, and sets the marker name to `mname`. """
function mcrowmean(m::Mocapdata;mname="joint"::String)::Mocapdata
    nr = size(m.data, 1)
    n = Matrix{Float64}(undef, nr, 3)
    X = Matrix(m.data)
    nm = m.nMarkers
    mn = m.markerName
    Threads.@threads for k in 1:3
        n[:,k:3:end] = nanmean(X[:,k:3:end],dim=2)
    end
    data = DataFrame(n,mname .* ["_x","_y","_z"])
    mt = deepcopy(m)
    mt.data = data
    mt.markerName = mname
    mt.nMarkers = 1
    return mt
end
