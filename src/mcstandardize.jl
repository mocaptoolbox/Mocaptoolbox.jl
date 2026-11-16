function mcstandardize(m::Union{Mocapdata,Normdata})
    m2 = deepcopy(m)
    Threads.@threads for k in eachcol(m2.data)
        k .= zscore(k)
    end
    return m2
end
zscore(k) = (k .- mean(k)) ./ std(k)
