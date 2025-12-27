function mcmerge(m::Mocapdata...)
    length(unique(map(x -> x.freq,m))) == 1 || error("Different frame rates. Cannot merge")
    dfs = map(x->x.data,m)
    minlen = minimum(nrow, dfs)
    if length(unique(nrow.(dfs))) > 1
        display("Different number of frames in the structures. The longer structure will be cut.")
        truncate(dfs) = [df[1:minlen,:] for df in dfs]
        dfs = truncate(dfs)
    end
    for k = 2:length(m)
        if sum(m[k].conn) > 0
            m[k].conn .+= maximum(m[k-1].conn)
        end
    end
    dfs = hcat(dfs...,makeunique=true)
    res = deepcopy(m[1])

    res.data = dfs
    res.conn = vcat([x.conn for x in m]...)
    res.markerName = vcat([x.markerName for x in m]...)
    res.nMarkers = sum([x.nMarkers for x in m])
    return res
end

*(m::Mocapdata...) = mcmerge(m...)

function mcmerge(m::Normdata...)
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
    res.markerName = vcat([x.markerName for x in m]...)
    res.nMarkers = sum([x.nMarkers for x in m])
    return res
end

*(m::Normdata...) = mcmerge(m...)
