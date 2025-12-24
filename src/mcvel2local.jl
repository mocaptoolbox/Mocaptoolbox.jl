function mcvel2local(m::Mocapdata,frontal=[2 6])
    # m: position data start with position data
    # frontal: 2 marker numbers defining the frontal plane ([leftmarker rightmarker]) can be tuple, vector, matrix... by default l and r thighs
    pos = m
    vel = mctimeder(pos)
    m1=mcgetmarker(pos,frontal[1])
    m2=mcgetmarker(pos,frontal[2])
    mlvect = Matrix(m2.data).-Matrix(m1.data)
    mlvect[:,3] .= 0
    mlvect./=Mocaptoolbox.normdim2(mlvect)
    nrows, ncols = size(mlvect)
    antunit = [0, 0, 1] #anteroposterior unit vector ponting to front
    apvect = Array{Float64}(undef,nrows,ncols)
    for k = 1:nrows
        apvect[k,:] = cross(antunit,mlvect[k,:])
    end
    veld1 = reshape(Matrix(vel.data),nrows,3,:)
    veld2 = Array{Float64}(undef,nrows,ncols,vel.nMarkers)
    for k = 1:vel.nMarkers
        veld2[:,1,k] = sum(veld1[:,:,k].*mlvect,dims=2)
        veld2[:,2,k] = sum(veld1[:,:,k].*apvect,dims=2)
        veld2[:,3,k] = veld1[:,3,k]
    end
    veld3 = reshape(veld2,nrows,:)
    res = deepcopy(vel)
    res.data = DataFrame(veld3,names(m.data))
    return res
end
