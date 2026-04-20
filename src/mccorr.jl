function mccorr(m1::Mocapdata, m2::Mocapdata, dim::Int64)
    n = m1.nMarkers
    @views c = [cor(m1.data[:, dim + 3*(i-1)], m2.data[:, dim + 3*(i-1)]) for i in 1:n]
    return DataFrame(c', m1.markerName)
end
function mccorr(m::Union{Mocapdata,Normdata}...)
    n = length(m)
    c = Vector{DataFrame}(undef,div((n*(n-1)),2))
    i = 1
    for j = 1:n
        for k = j+1:n
            c[i] = mccorr(m[j],m[k])
            i += 1
        end
    end
    df = vcat(c...) # this doesn't seem to work for norm data with 1 col
    r = combine(df, names(df) .=> mean)
    return r
end
function mccorr(m1::Union{Mocapdata,Normdata},m2::Union{Mocapdata,Normdata})
    n = size(m1.data, 2)
    @views c = [nancor(m1.data[:, i], m2.data[:, i]) for i in 1:n]
    return DataFrame(c',names(m1.data))
end
