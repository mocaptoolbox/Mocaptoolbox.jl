function mcfluidity(m::Mocapdata)
    v = mctimeder(m)
    a = mctimeder(v)
    vm = nanmean(Matrix(mcnorm(v).data),dims=1)
    am = nanmean(Matrix(mcnorm(a).data),dims=1)
    return (vm/am)[1];
end
