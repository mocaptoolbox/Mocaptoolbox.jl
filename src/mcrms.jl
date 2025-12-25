function mcrms(m::Mocapdata)
    r = nanrms(Matrix(m.data))
    return DataFrame(r,names(m.data))
end
function mcrms(m::Mocapdata,dim)
    r = nanrms(Matrix(m.data[:,dim:3:end]))
    return DataFrame(r,m.markerName)
end
function nanrms(x)
    sqrt.(nanmean(x.^2,dims=1))
end
