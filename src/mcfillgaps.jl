function mcfillgaps(m::Union{Mocapdata,Normdata};type="interp")
    f = deepcopy(m)
    M = Matrix(m.data)
    if type == "interp"
        t = 1:size(M,1)
        fillind = findall(vec(any(isnan.(M),dims=1) .& .!all(isnan.(M),dims=1))) # don't interpolate if the column is empty
        for k in fillind
            col = M[:,k]
            known = .!isnan.(col)
            # first/last NaNs replaced with first/last known value
            A = PCHIPInterpolation(col[known], t[known],extrapolation=ExtrapolationType.Constant)
            col[.!known] = A(t[.!known])
            M[:,k] = col
        end
        f.data = DataFrame(M,names(m.data))
    elseif type == "regress"
        for marker = 1:m.nMarkers
            N = m.nMarkers
            # find frames for which all markers are visible, use these for training the regression model
            trainframes=findall(vec(sum(isnan.(M),dims=2)).==0)
            # make independent variable
            iv = Matrix(mcgetmarker(m,setdiff(1:N,marker)).data)
            # make dependent variable
            dv = Matrix(mcgetmarker(m,marker).data)
            # train regression model for each of the three dimensions separately
            b = zeros((N-1)*3+1,3)
            X = hcat(iv[trainframes, :], ones(length(trainframes)))
            b = X \ dv[trainframes, :]
            # predict
            pred=[iv ones(size(iv,1),1)]*b;
            # find frames where DV is invisible and all IVs are visible
            predframes=findall(vec((sum(isnan.(iv),dims=2).==0) .& (sum(isnan.(dv),dims=2).>0)))
            # fill frames with predicted values
            f.data[predframes,3*marker .+ collect(-2:0)]=pred[predframes,:];
        end
        if sum(mcmissing(f)[1]) == 0
            return f
        end
        dv3 = Mocaptoolbox.loopmarkers(m,type="keepivnans")
        if any(isnan.(dv3))
            dv3 = Mocaptoolbox.loopmarkers(m,type="dropivnans")
        end
        f.data = DataFrame(dv3,names(m.data))
    end
    return f
end
function loopmarkers(m;type="keepivnans")
    mat = Matrix(m.data)
    dv3 = deepcopy(mat)
    miss = vec(mcmissing(m)[1])
    sortind = sortperm(miss)
    lm = sortind[miss .!= 0]
    lc = 1:size(mat,2);
    for k = lm
        dv = mat[:,in.(lc,[k*3-2:k*3])];
        if any(isnan.(dv))
            iv = mat[:,.!in.(lc,[k*3-2:k*3])]
            if type == "dropivnans"
                iv = iv[:,.!vec(any(isnan.(iv),dims=1))]
            end
            nandv = isnan.(dv);
            naniv = isnan.(iv);
            unsortednantypes = unique([nandv naniv],dims=1)
            nantypes = unsortednantypes[sortperm(vec(sum(unsortednantypes,dims=2))),:]
            i = 1;
            dv2 = Vector{Matrix{Float64}}()

            for j = 1:size(nantypes,1)

                if any(nantypes[j,1:3])
                    trainframesl = vec(.!all(hcat(nandv, naniv) .== nantypes[j, :]', dims=2))
                    keepLogic = .!nantypes[j,4:end];
                    iv2 = iv[:,keepLogic];
                    iv3 = iv2[:,vec(.!any(isnan.(iv2),dims=1))]
                    if size(iv3,2) != 0
                        ne = length(iv3[trainframesl,:])
                    else
                        ne = 0
                    end
                    trainframesl2 = vec(.!any([nandv naniv],dims=2))
                    if any(trainframesl2)
                        iv4 = iv[trainframesl2,:]; # IV if using simpler approach (mcfixrigidbody)
                        ne2 = length(iv4)
                    else
                        ne2 = 0
                    end
                    if ne > ne2 & any(.!keepLogic)
                        b = fill(NaN,size(iv3,2)+1,3)
                        X_train = hcat(iv3[trainframesl, :], ones(sum(trainframesl)))
                        b = [X_train \ dv[trainframesl, dim] for dim in 1:3]'
                        X_full = hcat(iv3, ones(size(iv3, 1)))
                        if any(isnan.(b[1]))
                            pred = fill(NaN,size(dv,1),size(dv,2))
                        else
                            pred = X_full * vcat(Matrix(b)...)'
                        end
                    else # old method (mcfixrigidbody)
                        b = fill(NaN,size(iv4,2)+1,3)
                        X_train = hcat(iv[trainframesl2, :], ones(sum(trainframesl2)))
                        b = [X_train \ dv[trainframesl2, dim] for dim in 1:3]'
                        X_full = hcat(iv, ones(size(iv, 1)))

                        if any(isnan.(b[1]))
                            pred = fill(NaN,size(dv,1),size(dv,2))
                        else
                            pred = X_full * vcat(Matrix(b)...)'
                        end
                    end
                    push!(dv2,dv)
                    dv2[i][.!trainframesl,:] = pred[.!trainframesl,:];
                    i += 1
                end
            end
        else
            dv2 = dv
        end
        if isa(dv2,Vector{Matrix{Float64}})
            s = sort(cat(dv2...; dims=3),dims=3)
            dv3[:,k*3-2:k*3] = s[:,:,1]
        else
            dv3[:,k*3-2:k*3] = dv2
        end
    end
    return dv3
end
