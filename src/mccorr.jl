function mccorr(m1::Union{Mocapdata,Normdata},m2::Union{Mocapdata,Normdata})
    c = diag(cor(Matrix(m1.data),Matrix(m2.data)))
    return DataFrame(c',names(m1.data))
end
function mccorr(m1::Mocapdata,m2::Mocapdata,dim)
    c = diag(cor(Matrix(m1.data[:,dim:3:end]),Matrix(m2.data[:,dim:3:end])),0)
    return DataFrame(c',m1.markerName)
end
