function mcmissing(m::Mocapdata)
    n = isnan.(Matrix(m.data[:,1:3:end]))
    mf = sum(n,dims=1);
    mm = sum(n,dims=2);
    mgrid = n;
return mf,mm,mgrid
end
