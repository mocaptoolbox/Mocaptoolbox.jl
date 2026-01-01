function mcrms(m::Union{Mocapdata,Normdata})
    r = nanrms(Matrix(m.data))
    return DataFrame(r,names(m.data))
end
function mcrms(m::Mocapdata,dim)
    @views r = nanrms(Matrix(m.data[:,dim:3:end]))
    return DataFrame(r,m.markerName)
end
function nanrms(x)
    sumsq = sum(x -> isnan(x) ? 0.0 : x*x, x; dims=1)
    count = sum(!isnan, x; dims=1)
    sqrt.(sumsq ./ count)
end
