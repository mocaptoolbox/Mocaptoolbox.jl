function mcfillgaps(m::Union{Mocapdata,Normdata})
    M = Matrix(m.data)
    t = 1:size(M,1)

    fillind = findall(vec(any(isnan.(M),dims=1) .& .!all(isnan.(M),dims=1))) # don't interpolate if the column is empty
    for k in fillind
        col = M[:,k]
        known = .!isnan.(col)
        # first/last NaNs replaced with first/last known value
        A = PCHIPInterpolation(col[known], t[known],extrapolation=ExtrapolationType.Constant)
        col[.!known] = A(t[.!known])
        M[:,k] = col
    end
    f = deepcopy(m)
    f.data = DataFrame(M,names(m.data))
    return f
end
