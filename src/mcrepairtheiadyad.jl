function mcrepairtheiadyad(r::Vector{Mocapdata})
"""
For dyadic Theia3D data. Fills nans in data based on other .tsv files created by Theia3D. To be used when multiple TSVs are generated instead of two. Example:

f = ["pose_filt_0.tsv", "pose_filt_1.tsv", "pose_filt_2.tsv", "pose_filt_3.tsv", "pose_filt_4.tsv"]
r = mcread.(f)
res1,res2 = mcrepairtheiadyad(r)
"""
    m = [Matrix(x.data) for x in r]
    ind = findall(.!isnan.([x[1] for x in m]))

    function fillmat(x,x1num,x2num)
        x1=x[x1num]
        x2=x[x2num]
        for k in eachindex(x)
            if k != x2num
                mask = isnan.(x1) .&& .!isnan.(x2) .&& .!isnan.(x[k])
                x1[mask] = x[k][mask]
            end
        end
        return x1
    end
    m1 = fillmat(m,ind[1],ind[2])
    m2 = fillmat(m,ind[2],ind[1])
    res1 = deepcopy(r[ind[1]])
    res1.data = DataFrame(m1, names(res1.data))
    res2 = deepcopy(r[ind[2]])
    res2.data = DataFrame(m2, names(res2.data))
    return res1, res2
end
