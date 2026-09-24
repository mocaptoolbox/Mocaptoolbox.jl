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
function mcpcaproj(m::Mocapdata) # proof of concept
    λ₂, v, t, meanx = pca(Matrix(m.data))
    d = deepcopy(m)
    d.data=DataFrame(t * v' .+ meanx,names(d.data))
    return d
end
function mcpcaproj(m::Vector{Mocapdata},pcind)
    mats = map(x->Matrix(x.data),m)
    s = size.(mats)
    heights = first.(s)
    if length(unique(s)) > 1
        error("Data must be equally sized")
    end
    nperset = s[1][1]
    λ₂, v, t, meanx = pca((vcat(mats...)))
    d = Vector{typeof(m[1])}(undef,length(pcind))
    i = 1
    for k in pcind
        d[i] = deepcopy(m[1])
        d[i].data=DataFrame(t[:,k] .* v[:,k]' .+ meanx,names(m[1].data)) # note that the mean is global
        d[i].nFrames = sum(heights)
        i += 1
    end
    σt = var(t,dims=1)
    nsets = length(s)
    σ = Array{Float64}(undef,nsets,length(σt))
    for k = 1:length(s)
        t₁ = t[(1:nperset).+(k-1)*nperset,:]
        σ = var(t₁,dims=1)./σt
    end
    σ = σ[pcind]
    return (;d,σ)
end
function mcpcaproj(m::Vector{Mocapdata};explainedvar = 90)
    mats = map(x->Matrix(x.data),m)
    s = size.(mats)
    heights = first.(s)
    if length(unique(s)) > 1
        error("Data must be equally sized")
    end
    nperset = s[1][1]
    λ₂, v, t, meanx = pca((vcat(mats...)))
    @show λ₂
    pcind = 1:findfirst(cumsum(λ₂) .> explainedvar/100)-1

    d = Vector{typeof(m[1])}(undef,length(pcind))
    i = 1
    for k in pcind
        d[i] = deepcopy(m[1])
        d[i].data=DataFrame(t[:,k] .* v[:,k]' .+ meanx,names(m[1].data)) # note that the mean is global
        d[i].nFrames = sum(heights)
        i += 1
    end
    σt = var(t,dims=1)
    nsets = length(s)
    σ = Array{Float64}(undef,nsets,length(σt))
    for k = 1:length(s)
        t₁ = t[(1:nperset).+(k-1)*nperset,:]
        σ = var(t₁,dims=1)./σt
    end
    σ = σ[pcind]
    return (;d,σ)
end
function pca(x)
    meanx = mean(x,dims=1)
    x .-= meanx
    r = x'*x;
    F = eigen(r)
    idx = sortperm(F.values,rev=true)
    λ = F.values[idx]
    v = F.vectors[:,idx]
    t = x*v
    λs = sum(λ)
    λ₂ = λ/λs
    return (;λ₂, v, t, meanx)
end
