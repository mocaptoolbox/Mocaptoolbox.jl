"""
mctimeder(m,n,freq;window_size::Int=7)
m = data
n = time derivative
freq = frame rate of the data
"""
function mctimeder(m,n,freq;window_size::Int=7)
    data = differentiate(m,n,window_size) .* freq^n
    return data
end
function mctimeder(m::Union{Mocapdata,Normdata},n::Int=1;window_size::Int=7)::Union{Mocapdata,Normdata}
    data = differentiate(m.data,n,window_size) .* m.freq^n
    der = deepcopy(m)
    der.data .= data
    der.timederOrder = n
    return der
end
    function differentiate(d::DataFrame,n::Int,f::Int)::Matrix{Float64}
        nrow,ncol = size(d)
        pol_order=n
        n > 0 ? pol_order += 1 : nothing
        f = (4*n+f-4)::Int64
        tmp = zeros(nrow,ncol)::Matrix{Float64}
        for k = 1:ncol
            tmp[:,k] = smoothderiv(d[:,k],pol_order,f,n)::Vector{Float64}
        end
        tmp=(tmp[div(f+1,2):end-div(f+1,2),:])::Matrix{Float64}
        @views der = ([repeat(tmp[1,:]',div((f-1),2),1);tmp;repeat(tmp[end,:]',div((f+1),2),1)])::Matrix{Float64}
        return der
    end
    function smoothderiv(data::Vector{Float64},k::Int,f::Int,o::Int)::Vector{Float64}
        sg = savitzky_golay(data,f,k,deriv=o)::SavitzkyGolay.SGolayResults{Float64, Float64, Float64}
        return sg.y
    end
