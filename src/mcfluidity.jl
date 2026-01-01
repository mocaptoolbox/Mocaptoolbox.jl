function mcfluidity(m::Mocapdata)
    v = mctimeder(m)
    a = mctimeder(v)
    vm = nanmean(Matrix(mcnorm(v).data),dims=1)::Matrix{Float64}
    am = nanmean(Matrix(mcnorm(a).data),dims=1)::Matrix{Float64}
    return (vm/am)[1];
end
