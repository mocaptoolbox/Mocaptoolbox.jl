function mcmerge(m::mocapdata...)
    length(unique(map(x -> x.freq,m))) == 1 || error("Different frame rates. Cannot merge")
    dfs = map(x->x.data,m)
    minlen = minimum(nrow, dfs)
    if length(unique(nrow.(dfs))) > 1
        display("Different number of frames in the structures. The longer structure will be cut.")
        truncate(dfs) = [df[1:minlen,:] for df in dfs]
        dfs = truncate(dfs)
    end
    dfs = hcat(dfs...,makeunique=true)
    res = deepcopy(m[1])
    res.data = dfs
    return res
end

*(m::mocapdata...) = mcmerge(m...)
