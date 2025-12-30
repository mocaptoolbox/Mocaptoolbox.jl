function mcinterpersonaldist(m1::Mocapdata,m2::Mocapdata)
    """
    Calculate, for each marker, horizontal interpersonal Euclidean distance.
    """
    if !all(size(m1.data) .== size(m2.data))
        error("Both mocap structs must have the same size")
    end
    x1 = Matrix(m1.data)
    x2 = Matrix(m2.data)
    mn = m1.nMarkers
    r,c = size(x1)
    resh(x,mn) = reshape(x,r,3,mn)
     r1,r2 = resh.([x1,x2],mn)
    eudist(x,y) = sqrt.((x[:,1] .- y[:,1]).^2 .+ (x[:,2] .- y[:,2]).^2)
    d = Vector{Vector{Float64}}(undef,mn)
    for k = 1:mn
        d[k] = eudist(r1[:,:,k],r2[:,:,k])
    end
    return DataFrame(hcat(d...),m1.markerName)
end
