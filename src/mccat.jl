    """
    concatenates motion-capture data in a given dimension based on translation. Limits are based on data min and max.
    """
function mccat(m::Mocapdata...;dim::Int64)::Mocapdata
    mat = map(x->Matrix(x.data),m)
    ex = Vector{Tuple{Float64, Float64}}(undef, length(m))

    for k = eachindex(mat)
        d = mat[k][:,dim:3:end]
        ex[k] = extrema(d[.!isnan.(d)])
    end
    mind = minimum([x[1] for x in ex])
    maxd = maximum([x[2] for x in ex])
    height = maxd-mind
    v = Vector{Mocapdata}(undef, length(m))
    tv = [0.0,0.0,0.0]
    for k = eachindex(m)
        tv[dim] = (k-1)*-height
        v[k] = mctranslate(m[k],tv)

    end
    return mcmerge(v...)
end
