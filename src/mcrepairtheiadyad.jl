"""
For dyadic Theia3D data. Fills nans in data based on other .tsv files created by Theia3D. To be used when multiple TSVs are generated instead of two. Example:

f = ["pose_filt_0.tsv", "pose_filt_1.tsv", "pose_filt_2.tsv", "pose_filt_3.tsv", "pose_filt_4.tsv"]
r = mcread.(f)
res1,res2 = mcrepairtheiadyad(r)
"""
function mcrepairtheiadyad(r::Vector{Mocapdata})
    allMats = [Matrix(x.data) for x in r]
    firstMat = []
    for k = 1:length(allMats)
        if any(.!isnan.(allMats[k][1,:]))
            push!(firstMat,k)
        end
    end
    data1,data2 = [allMats[x] for x in firstMat]
    allMats = allMats[setdiff(collect(1:length(allMats)),firstMat)]
    d1nanrows = vec(all(isnan.(data1),dims=2))
    allnanrows = [all(isnan.(x),dims=2) for x in allMats]
    allnanrows = hcat(allnanrows...)
    i = 1
    inds = []
    cur = []
    for k = 1:length(allMats)
        cur = allnanrows[:,k]
        if all(cur[.!d1nanrows]) & any(cur[d1nanrows])
            data1[.!cur,:] = allMats[k][.!cur,:]
            push!(inds,k)
        end
    end
    allMats = allMats[setdiff(collect(1:length(allMats)),inds)]
    for k = 1:length(allMats)
        if all(isnan.(data2[vec(any(.!isnan.(allMats[k]),dims=2)),:]))
            data2[vec(any(.!isnan.(allMats[k]),dims=2)),:] = allMats[k][vec(any(.!isnan.(allMats[k]),dims=2)),:]
        elseif any(all(any(.!isnan.(allMats[k]),dims=2),dims=2) .& all(isnan.(data1),dims=2))
            assignable = vec(all(any(.!isnan.(allMats[k]),dims=2),dims=2) .& all(isnan.(data1),dims=2))
            data1[assignable,:] = allMats[k][assignable,:]
            allMats[k][assignable,:] = fill(NaN,size(allMats[k][assignable,:]))
            if all(isnan.(data2[vec(any(.!isnan.(allMats[k]),dims=2)),:]))
                data2[vec(any(.!isnan.(allMats[k]),dims=2)),:] = allMats[k][vec(any(.!isnan.(allMats[k]),dims=2)),:]
            elseif all(any(isnan.(data2[vec(any(.!isnan.(allMats[k]),dims=2)),:])))
                data2[vec(all(isnan.(data2),dims=2)),:] = allMats[k][vec(all(isnan.(data2),dims=2)),:]
            elseif any(map(x -> cor(x[.!isnan.(allMats[k])],allMats[k][.!isnan.(allMats[k])]),[data1,data2]) .>.99)
            end
        else
            assignable = vec(all(any(.!isnan.(allMats[k]),dims=2),dims=2) .& all(isnan.(data2),dims=2))
            data2[assignable,:] = allMats[k][assignable,:]
            allMats[k][assignable,:] = fill(NaN,size(allMats[k][assignable,:]))
            if any(any(.!isnan.(allMats[k]),dims=2))
                assignable = vec(all(any(.!isnan.(allMats[k]),dims=2),dims=2) .& all(isnan.(data1),dims=2))
                if any(assignable)
                    data1[assignable,:] = allMats[k][assignable,:];
                    allMats[k][assignable,:] = fill(NaN,size(allMats[k][assignable,:]))
                else
                end
            end
        end
    end
    d1,d2 = deepcopy.([r[1],r[2]])
    d1.data = DataFrame(data1,names(r[1].data))
    d2.data = DataFrame(data2,names(r[2].data))
    return d1,d2
end
