struct Sumdiags
    sumdiags::Vector{Float64}
    lags::Vector{Float64} # in seconds
    peakval::Float64
    peaklag::Float64 # in seconds
end
struct CrossSim{T, X<:AbstractVecOrMat{T}, Y<:AbstractVecOrMat{T}} <: AbstractMatrix{T}
    x::X
    y::Y
end
Base.size(m::CrossSim) = (size(m.x, 1), size(m.y, 1))
Base.getindex(m::CrossSim, i::Int, j::Int) = m.y[j, :]' * m.x[i, :]

"""
Compute sum across diagonals for the cross similarity matrix XYᵀ betwen two multivariate time series.
The `maxlag` parameter specifies the maximum time lag (in seconds) for analysys. It is set to 2 s by default, meaning that only the sum across diagonals located between lags -2 s and 2 s is computed.
The `sumlags` (default=false) parameter controls whether or not to sum the corresponding lags.
"""
function mcdrp(m1,m2;maxlag=2,sumlags=false,abs=false)
    m1.freq !== m2.freq && @warn("There is a frame rate mismatch between the two MoCap structs. The frame rate of the first MoCap struct is used for computing the maximum time lag")
    if sumlags
        xs = Σdiags_sumlags(Matrix(m1.data),Matrix(m2.data),m1.freq;maxlag=maxlag,abs=abs)
    else
        xs = Σdiags(Matrix(m1.data),Matrix(m2.data),m1.freq;maxlag=maxlag,abs=abs)
    end
end
"""
Sum across diagonals for the cross similarity matrix XYᵀ betwen two multivariate time series. The 'maxlag' parameter specifies the maximum time lag (in seconds) for analysys. It is set to 2 s by default, meaning that only the sum across diagonals located between lags -2 s and 2 s is computed.
"""
function Σdiags(p1,p2,fs;maxlag=2,abs=false)
    m = CrossSim(p1,p2)
    dind = [-(size(m,1)-1):0; 1:(size(m,1)-1)]
    lagsall = dind./fs
    ind = x-> -maxlag <= x <= maxlag
    lags = filter(ind,lagsall)
    lagswindowind = dind[ind.(lagsall)]
    sumdiagonal(x,k) = sum(diagview(x,k))
    Σdiags = [sumdiagonal(m,k) for k in lagswindowind]
    if abs
        Σdiags = Base.abs.(Σdiags)
    end
    peakval = maximum(Σdiags)
    peaklag = lags[argmax(Σdiags)]
    s = Sumdiags(Σdiags,lags,peakval,peaklag)
end
"""
Sum across diagonals for the cross similarity matrix XYᵀ betwen two multivariate time series. The 'maxlag' parameter specifies the maximum time lag (in seconds) for analysys. It is set to 2 s by default, meaning that only the sum across diagonals located between lags -2 s and 2 s is computed. The sums across diagonals of corresponding lags (e.g., -2 and 2 s) are subsequently summed together. Before this final summation, the absolute part can be computed with the parameter `abs` (default = false)
"""
function Σdiags_sumlags(p1,p2,fs;maxlag=2,abs=false)
    m = CrossSim(p1,p2)
    dind = [-(size(m,1)-1):0; 1:(size(m,1)-1)]
    lagsall = dind./fs
    ind = x-> -maxlag <= x <= maxlag
    lags = filter(ind,lagsall)
    lagswindowind = dind[ind.(lagsall)]
    sumdiagonal(x,k) = sum(diagview(x,k))
    Σdiags = [sumdiagonal(m,k) for k in lagswindowind]
    if abs
        Σdiags = Base.abs.(Σdiags)
    end
    ΣΣdiags_ = Σdiags .+ reverse(Σdiags)
    indshalf = length(Σdiags)÷2+1:length(Σdiags)
    ΣΣdiags = ΣΣdiags_[indshalf]
    halflags = lags[indshalf]
    peakval = maximum(ΣΣdiags)
    peaklag = halflags[argmax(ΣΣdiags)]
    s = Sumdiags(ΣΣdiags,halflags,peakval,peaklag)
end
