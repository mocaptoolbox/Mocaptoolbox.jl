function mcpcaproj(m::Mocapdata,pcind;combine=true)
    λ₂, v, t, meanx = pca(Matrix(m.data))
    if combine
        d = deepcopy(m)
        d.data=DataFrame(t[:,pcind] * v[:,pcind]' .+ meanx,names(d.data))
    else
        d = Vector{typeof(m)}(undef,length(pcind))
        for k in pcind
            d[k] = deepcopy(m)
            d[k].data=DataFrame(t[:,k] .* v[:,k]' .+ meanx,names(d[k].data))
        end
    end
    return d
end
function mcpcaproj(m::Mocapdata)
    λ₂, v, t, meanx = pca(Matrix(m.data))
    d = deepcopy(m)
    d.data=DataFrame(t * v' .+ meanx,names(d.data))
    return d
end
function mcpcaproj(m::Vector{Mocapdata},pcind;combine=true,localdemean=false)
    mats = map(x->Matrix(x.data),m)
    s = size.(mats)
    heights = first.(s)
    if length(unique(s)) > 1
        error("Data must be equally sized")
    end
    nperset = s[1][1]
    if localdemean
        meanx = map(x->mean(x,dims=1),mats)
        mats = map((x,y) -> x .- y,mats,meanx)
        λ₂, v, t = pca((vcat(mats...)),demean=false)
    else
        λ₂, v, t, meanx = pca((vcat(mats...)))
    end
    if combine
        d = deepcopy(m[1])
        if localdemean
            localmeanx = vcat(map((x,y) -> repeat(x,y),meanx,heights)...)
            d.data=DataFrame(t[:,pcind] * v[:,pcind]' .+ localmeanx,names(m[1].data)) # note that the mean is global
        else
            d.data=DataFrame(t[:,pcind] * v[:,pcind]' .+ meanx,names(m[1].data)) # note that the mean is global
        end
        d.nFrames = size(d.data,1)
    else
    d = Vector{typeof(m[1])}(undef,length(pcind))
        i = 1
        for k in pcind
            d[i] = deepcopy(m[1])
            d[i].data=DataFrame(t[:,k] .* v[:,k]' .+ meanx,names(m[1].data)) # note that the mean is global
            d[i].nFrames = sum(heights)
            i += 1
        end
    end
    σt = var(t,dims=1)
    nsets = length(s)
    σ = Array{Float64}(undef,nsets,length(σt))
    for k = 1:length(s)
        t₁ = t[(1:nperset).+(k-1)*nperset,:]
        σ[k,:] = var(t₁,dims=1)./σt
    end
    σ = σ[:,pcind]
    return (;d,σ)
end
function mcpcaproj(m::Vector{Mocapdata};explainedvar = 90,localdemean=false,plotallloadings=false,plotloadingspc=0)
    mats = map(x->Matrix(x.data),m)
    s = size.(mats)
    heights = first.(s)
    if length(unique(s)) > 1
        error("Data must be equally sized")
    end
    nperset = s[1][1]
    if localdemean
        meanx = map(x->mean(x,dims=1),mats)
        mats = map((x,y) -> x .- y,mats,meanx)
        λ₂, v, t = pca((vcat(mats...)),demean=false)
    else
        λ₂, v, t, meanx = pca((vcat(mats...)))
    end
    if plotallloadings
        f = Figure()
        ax = Axis(f[1,1],xlabel="PC",ylabel="Variable")
        plot!(ax,v)
        f
    end
    if plotloadingspc>0
        f = Figure()
        ax = Axis(f[1,1],xlabel="PC$plotloadingspc",ylabel="Variable")
        blabels = repeat(m[1].markerName,inner=3) .* "_" .* repeat(["x","y","z"],m[1].nMarkers)
        barplot!(ax,v[:,plotloadingspc],bar_labels=blabels)
        f
    end
    pcind = 1:findfirst(cumsum(λ₂) .> explainedvar/100)-1

    d = Vector{typeof(m[1])}(undef,length(pcind))
    i = 1
    for k in pcind
        d[i] = deepcopy(m[1])
        if localdemean
            localmeanx = vcat(map((x,y) -> repeat(x,y),meanx,heights)...)
            d[i].data=DataFrame(t[:,k] .* v[:,k]' .+ localmeanx,names(m[1].data)) # note that the mean is global
        else
            d[i].data=DataFrame(t[:,k] .* v[:,k]' .+ meanx,names(m[1].data)) # note that the mean is global
        end

        d[i].nFrames = sum(heights)
        i += 1
    end
    σt = var(t,dims=1)
    nsets = length(s)
    σ = Array{Float64}(undef,nsets,length(σt))
    for k = 1:length(s)
        t₁ = t[(1:nperset).+(k-1)*nperset,:]
        σ[k,:] = var(t₁,dims=1)./σt
    end
    σ = σ[:,pcind]
    return (;d,σ)
end
function pca(x;demean=true,plotloadings=false)
    if demean
        meanx = mean(x,dims=1)
        x .-= meanx
    end
    r = x'*x;
    F = eigen(r)
    idx = sortperm(F.values,rev=true)
    λ = F.values[idx]
    v = F.vectors[:,idx]
    t = x*v
    λs = sum(λ)
    λ₂ = λ/λs
    if plotloadings
        f = Figure()
        ax = Axis(f[1,1],xlabel="PC",ylabel="Variable")
        plot!(ax,v)
        f
    end
    if demean
        return (;λ₂, v, t, meanx)
    else
        return (;λ₂, v, t)
    end
end
