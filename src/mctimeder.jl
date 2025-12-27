function mctimeder(m::Union{Mocapdata,Normdata},n::Int=1;window_size::Int=7)
    function differentiate(d::DataFrame,n::Int,f::Int)
        ncol = size(d,2)
        nrow = size(d,1)
        pol_order=n
        n > 0 ? pol_order += 1 : nothing
        f = 4*n+f-4
        tmp = zeros(nrow,ncol)
        for k = 1:ncol
            tmp[:,k] = smoothderiv(d[:,k],pol_order,f,n)
        end
        tmp=tmp[div(f+1,2):end-div(f+1,2),:];
        der = [repeat(tmp[1,:]',div((f-1),2),1);tmp;repeat(tmp[end,:]',div((f+1),2),1)]
        return der
    end
    function smoothderiv(data::Vector{Float64},k::Int,f::Int,o::Int)
        sg = savitzky_golay(data,f,k,deriv=o)
        return sg.y
    end
    data = differentiate(m.data,n,window_size) .* m.freq^n
    der = deepcopy(m)
    der.data .= data
    der.timederOrder = n
    return der
end
