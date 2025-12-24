function mcfluidity(m::Mocapdata)
    v = mctimeder(m)
    a = mctimeder(v)
    vm = mean(Matrix(mcnorm(v).data),dims=1)
    am = mean(Matrix(mcnorm(a).data),dims=1)
    return vm/am;
end
