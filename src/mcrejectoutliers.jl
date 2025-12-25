    """
    Reject outlier data based on pairwise Euclidean distances between markers.
    Example: If the distance between two markers for a given time point is higher or lower than Tol, both markers are converted to NaNs for that time point.
    Tol is in units of measurement, e.g. default is 250 mm for Qualisys MoCap/Theia3D data.
    """
function mcrejectoutliers(m::Mocapdata;fun=nanmedian::Function,tol=250::Float64)
    x = Matrix(m.data)
    r,c = size(x)
    dm = Array{Float64}(undef,m.nMarkers,m.nMarkers,r);
    rs = [Matrix{Float64}(undef,3,m.nMarkers) for _ in 1:r];
    for k = 1:r
        rs[k] = reshape(x[k,:],3,:);
        dm[:,:,k] = pairwise(Euclidean(), rs[k], dims=2);
    end
    applyfun(dm,fun) = dropdims(fun(dm,dims=3),dims=3)
    absdev = abs.(dm .- applyfun(dm,fun))
    absdev[absdev .> tol] .= NaN
    for f = 1:r
        for k = 1:m.nMarkers-1
            for j = (k+1):m.nMarkers
                if isnan(absdev[k,j,f])
                    rs[f][:,[k,j]] .= NaN
                end
            end
        end
        x[f,:] = reshape(rs[f],1,:)
    end
    res = deepcopy(m)
    res.data = DataFrame(x,names(m.data))
    return res
end
