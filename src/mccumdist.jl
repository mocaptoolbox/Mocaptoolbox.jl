function mccumdist(m::Mocapdata)
    r,c=size(m.data)
    d=Matrix(m.data)
    if m.type == "MoCap data"
        d2 = reshape(d,r,3,:)
    elseif m.type == "Norm data"
        d2 = reshape(d,r,1,:)
    end
    absdiff(x) = abs.(diff(x,dims=1))
    d3 = [zeros(1,size(d2,2),m.nMarkers); absdiff(d2)]
    if m.type == "MoCap data"
        d4 = cumsum(normdim2(d3),dims=1)
    elseif m.type == "Norm data"
        d4 = cumsum(d3,dims=1)
    end
    res = deepcopy(m)
    res.data = DataFrame(reshape(d4,r,m.nMarkers),m.markerName)
    return res
end
