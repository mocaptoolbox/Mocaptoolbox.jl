    """
    Translates motion-capture data by a vector.
     syntax
     d2 = mctranslate(d, X);

     input parameters
     d: MoCap structure
     X: translation vector
    """
function mctranslate(m::Mocapdata,X::Vector)
    x = Matrix(m.data)
    for k = 1:3
        x[:,k:3:end] .+= .+ X[k]
    end
    res = deepcopy(m)
    res.data = DataFrame(x,names(m.data))
    return res
end
