function mcrms(m::Union{Mocapdata,Normdata})
    r = nanrms(Matrix(m.data))
    return DataFrame(r,names(m.data))
end
function mcrms(m::Mocapdata,dim::Int64)
    @views r = nanrms(Matrix(m.data[:,dim:3:end]))
    return DataFrame(r,m.markerName)
end
function mcrms(m::Union{Mocapdata,Normdata}...)
    ms = map(x -> Matrix(x.data),m)
    nom = vec(nanrms(sum(cat(ms...;dims=3),dims=3)))
    denom = vec(sum(nanrms.(ms)))
    r = nom./denom
    return DataFrame(r',names(m[1].data))
end
function nanrms(x)
    sumsq = sum(x -> isnan(x) ? 0.0 : x*x, x; dims=1)
    count = sum(!isnan, x; dims=1)
    sqrt.(sumsq ./ count)
end
