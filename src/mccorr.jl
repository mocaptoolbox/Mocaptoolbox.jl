function mccorr(m1::Union{Mocapdata,Normdata},m2::Union{Mocapdata,Normdata})
    n = size(m1.data, 2)
    @views c = [cor(m1.data[:, i], m2.data[:, i]) for i in 1:n]
    return DataFrame(c',names(m1.data))
end
function mccorr(m1::Mocapdata, m2::Mocapdata, dim)
    n = m1.nMarkers
    @views c = [cor(m1.data[:, dim + 3*(i-1)], m2.data[:, dim + 3*(i-1)]) for i in 1:n]
    return DataFrame(c', m1.markerName)
end
