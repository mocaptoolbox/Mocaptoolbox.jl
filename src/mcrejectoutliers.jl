    """
    Reject outlier data based on pairwise Euclidean distances between markers.
    Example: If the distance between two markers for a given time point is higher or lower than `thres`, both markers are converted to NaNs for that time point.
    Thres is in units of measurement, e.g. default is 250 mm for Qualisys MoCap/Theia3D data.
    """
function mcrejectoutliers(m::Mocapdata;thres=250::Real)
    x = Matrix(m.data)
    r,c = size(x)
    nMarkers = m.nMarkers
    dm = Array{Float64}(undef,nMarkers,nMarkers,r);
    rs = [Matrix{Float64}(undef,3,nMarkers) for _ in 1:r];
    for k = 1:r
        rs[k] = reshape(x[k,:],3,:);
        dm[:,:,k] = pairwise(Euclidean(), rs[k], dims=2);
    end
    med(dm) = dropdims(nanmedian(dm,dims=3),dims=3)
    absdev = abs.(dm .- med(dm))
    absdev[absdev .> thres] .= NaN
    for f = 1:r
        for k = 1:nMarkers-1
            for j = (k+1):nMarkers
                if isnan(absdev[k,j,f])
                  @inbounds rs[f][:,[k,j]] .= NaN
                end
            end
        end
        x[f,:] = reshape(rs[f],1,:)
    end
    res = deepcopy(m)
    res.data = DataFrame(x,names(m.data))
    return res
end
