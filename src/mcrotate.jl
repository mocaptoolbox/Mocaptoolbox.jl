    """
    rotation
    θ: rotation angle (in degrees)
     axis: rotation axis (optional, default = [0, 0, 1])
     point: point through which the rotation axis goes (optional, default is the centroid of markers over time)
    """
function mcrotate(m::Mocapdata,θ::Number;axis::Vector = [0, 0, 1],point=Vector{Union{Real,Missing}}(missing,3))
    θ = (θ*π)/180
    x = Matrix(m.data)
    r,c = size(x)
    nm = m.nMarkers
    x3 = reshape(x,r,3,nm)
    if all(ismissing.(point))
        point = nanmean.([x3[:,k,:] for k in 1:3])
    end
    R = AngleAxis(θ, axis...)
    r3 = similar(x3)
    point_reshaped = reshape(point, 1, 3)
    for j in 1:nm
        r3[:,:,j] = (R * (x3[:,:,j] .- point_reshaped)')' .+ point'
    end
    x2 = reshape(r3,r,c)
    res = deepcopy(m)
    res.data = DataFrame(x2,names(m.data))
    return res
end
