"""
Compute mean across time
"""
function mcmean(m::Mocapdata)
    tmp = Matrix(m.data)
    mn = mean(tmp,dims=1)
end
function mcmean(m)
    mn = mean(m,dims=1)
end
