function mc2frontal(m::Mocapdata,marker1::Int,marker2::Int)
    mc2frontal(m::Mocapdata,marker1::Int,marker2::Int,method="mean")
end
function mc2frontal(m::Mocapdata,marker1::Int,marker2::Int,method)
    m2 = deepcopy(m)
    dat = Matrix(m2.data)
    if method=="mean"
        dat2 = frontal(dat,marker1,marker2)
    elseif method=="frame"
        dat2 = vcat(frontal.(eachrow(dat),marker1,marker2)...)
    end
    m2.data = DataFrame(dat2,names(m.data));
    return m2
end
function frontal(dat,marker1,marker2)
    # select markers 1 and 2
    tmp = dat[:,[3 .* marker1 .+ (-2:0); 3 .* marker2 .+ (-2:0)]]; # get markers
    x1, y1, x2, y2 = map(x-> tmp[:,x],[1 2 4 5]) # get x y coords
    θ₀ = atan.(y1-y2,x1-x2) # get angle of position vector
    ρ₀ = hypot.(x1-x2,y1-y2) # get length of position vector
    θ = 180 .-180*θ₀/π # supplementary angle in degrees
    dat2 = mcrotate(dat,θ, axis=[0, 0, 1])
end
function frontal(dat::SubArray, marker1,marker2)
    tmp = dat[[3 .* marker1 .+ (-2:0); 3 .* marker2 .+ (-2:0)],:]; # get markers
    x1, y1, x2, y2 = map(x-> tmp[x],[1 2 4 5]) # get x y coords
    θ₀ = atan.(y1-y2,x1-x2) # get angle of position vector
    ρ₀ = hypot.(x1-x2,y1-y2) # get length of position vector
    θ = 180 .-180*θ₀/π # supplementary angle in degrees
    dat2 = mcrotate(dat',θ, axis=[0, 0, 1])
end
