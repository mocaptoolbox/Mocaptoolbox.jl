function mccomplexity(m::Union{Mocapdata,Normdata})
    d = Matrix(m.data)
    d .-= mean(d,dims=1)
    l = eigvals(d'*d)
    l2 = l/sum(l)
    l2 = max.(l2,eps())
    c=exp(-sum(l2.*log.(l2)))
end
