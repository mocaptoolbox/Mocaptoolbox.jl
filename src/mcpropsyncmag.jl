"""
`mcpropsyncmag_stft(m::Mocapdata,Normdata},tempo::Real;bwratio::Float64=.4,power=false::Bool)`

Computes proportion of synchronized magnitude of MoCap data for a target tempo (in BPM). A wavelet transform -based dynamic bandpass filtering is applied.

"""
function mcpropsyncmag_stft(m::Union{Mocapdata,Normdata},tempo::Real;bwratio::Float64=.4,power=false::Bool)
    m = mcfillgaps(m)
    d = Matrix(m.data)
    durs = getdurs(m.nFrames,m.freq)
    t = 0:(1/m.freq):durs;
    f = tempo/m.freq
    n = size(d,2)
    wt = Vector{Array}(undef,n)
    wt2 = Vector{Array}(undef,n)
    wfreq = Vector{Array}(undef,n)
    p = Vector{Float64}(undef,n)
    scale = []
    for j = 1:n
        wt[j], wfreq[j] = getstft(d[:,j]);
        wt2[j] = copy(wt[j])
        for k = 1:size(wt[j],1)
            scale = pdf(Normal(f,bwratio*f),wfreq[j])
            scale /= maximum(scale)
            wt2[j][k,:] = wt[j][k,:] .* scale;
        end
        wt2[j][isnan.(wt2[j])] .= 0
        if power == false
            p[j] = sum(abs.(wt2[j])) / sum(abs.(wt[j]))
        else
            p[j] = sum(abs.(wt2[j]).^2) / sum(abs.(wt[j]).^2)
        end
    end
    p = makedf(p,m)
end

"""
`mcpropsyncmag(m::Mocapdata,Normdata},tempo::Real;bwratio::Float64=.4,power=false::Bool)`

Computes proportion of synchronized magnitude of MoCap data for a target tempo (in BPM). A wavelet transform -based dynamic bandpass filtering is applied. Currently using MATLAB's cwt().

"""
function mcpropsyncmag(m::Union{Mocapdata,Normdata},tempo::Real;bwratio::Float64=.4,power=false::Bool)
    m = mcfillgaps(m)
    d = Matrix(m.data)
    durs = getdurs(m.nFrames,m.freq)
    t = 0:(1/m.freq):durs;
    f = tempo/m.freq
    n = size(d,2)
    wt = Vector{Array}(undef,n)
    wt2 = Vector{Array}(undef,n)
    wfreq = Vector{Array}(undef,n)
    p = Vector{Float64}(undef,n)
    scale = []
    for j = 1:n
        wt[j], wfreq[j] = getcwt(d[:,j],m.freq);
        wt2[j] = copy(wt[j])
        for k = 1:size(wt[j],2)
            scale = pdf(Normal(f,bwratio*f),wfreq[j])
            scale /= maximum(scale)
            wt2[j][:,k] = wt[j][:,k] .* scale; # this needs to be changed [k,:] if not using matlab
        end
        wt2[j][isnan.(wt2[j])] .= 0
        if power == false
            p[j] = sum(abs.(wt2[j])) / sum(abs.(wt[j]))
        else
            p[j] = sum(abs.(wt2[j]).^2) / sum(abs.(wt[j]).^2)
        end
    end
    p = makedf(p,m)
end
"""
`mcpropsyncmag(m::Mocapdata,Normdata},tempo::Real, iter::Int64 ;bwratio::Float64=.4,power=false::Bool)`

Computes proportion of synchronized magnitude of MoCap data for a target tempo (in BPM).
A wavelet transform -based dynamic bandpass filtering is applied. A baseline mean wavelet transform is subtracted from the data to normalize energy

"""
function mcpropsyncmag(m::Union{Mocapdata,Normdata},tempo::Real,iter::Int64;bwratio::Float64=.4,power=false::Bool)
    m = mcfillgaps(m)
    d = Matrix(m.data)
    durs = getdurs(m.nFrames,m.freq)
    t = 0:(1/m.freq):durs;
    f = tempo/m.freq
    n = size(d,2)
    wt = Vector{Array}(undef,n)
    wt2 = Vector{Array}(undef,n)
    wtr = Vector{Array}(undef,iter)
    wfreq = Vector{Array}(undef,n)
    p = Vector{Float64}(undef,n)
    scale = []
    for j = 1:n
        wt[j], wfreq[j] = getcwt(d[:,j]);
        for k = 1:iter
            wtr[k], _ = getcwt(scramblephases(d[:,j]));
        end
        mean_wtr = dropdims(mean(cat(wtr...,dims=3),dims=3);dims=3)
        wt[j] -= mean_wtr
        wt2[j] = copy(wt[j])
        for k = 1:size(wt[j],1)
            scale = pdf(Normal(f,bwratio*f),wfreq[j])
            scale /= maximum(scale)
            wt2[j][k,:] = wt[j][k,:] .* scale;
        end
        wt2[j][isnan.(wt2[j])] .= 0
        if power == false
            p[j] = sum(abs.(wt2[j])) / sum(abs.(wt[j]))
        else
            p[j] = sum(abs.(wt2[j]).^2) / sum(abs.(wt[j]).^2)
        end
    end
    p = makedf(p,m)
end


"""
`mcpropsyncmag(m::Mocapdata,Normdata},beattimes::AbstractVector{<:Real};bwratio::Float64=.4,power=false::Bool)`

Computes proportion of synchronized magnitude of MoCap data for a target vector with individual beat times (in seconds). A wavelet transform -based dynamic bandpass filtering is applied.

"""
function mcpropsyncmag(m::Union{Mocapdata,Normdata},beattimes::AbstractVector{<:Real};bwratio::Float64=.4,power=false::Bool)
    m = mcfillgaps(m)
    d = Matrix(m.data)
    durs = getdurs(m.nFrames,m.freq)
    t = 0:(1/m.freq):durs;
    nbtt = length(beattimes)-1.0
    phase = cubic_interp(beattimes,0:nbtt,t,extrap=ExtendExtrap())
    f=diff(phase)*m.freq;
    n = size(d,2)
    wt = Vector{Array}(undef,n)
    wt2 = Vector{Array}(undef,n)
    wfreq = Vector{Array}(undef,n)
    p = Vector{Float64}(undef,n)
scale = []
    for j = 1:n
        wt[j], wfreq[j] = getcwt(d[:,j]);
        wt2[j] = copy(wt[j])
        for k = 1:size(wt[j],1)
            scale = pdf(Normal(f[k],bwratio*f[k]),wfreq[j])
            scale /= maximum(scale)
            wt2[j][k,:] = wt[j][k,:] .* scale;
        end
        wt2[j][isnan.(wt2[j])] .= 0
        if power == false
            p[j] = sum(abs.(wt2[j]))/sum(abs.(wt[j]))
        else
            p[j] = sum(abs.(wt2[j]).^2)/sum(abs.(wt[j]).^2)
        end
    end
    p = makedf(p,m)
end
getdurs(nFrames,freq) = nFrames/freq
getdims(data,markerName) = collect(1:size(data,2)/length(markerName));
function getstft(d)
    W = 64            # Window length
    w = ones(W)       # Rectangular analysis window
    H = 10            # Hop
    L = W - H         # Overlap

end
function getcwt(d,f)
    mat"[$w $f] = cwt($d,double($f))"
    return w, f
end
function getcwtt(d)
    n = length(d)
    #c = wavelet(Morlet())
    # c = wavelet(Morlet(π/2), Q = 400, β = 2, s = 500, extraOctaves = -1); freqs = getMeanFreq(computeWavelets(n, c)[1])[1:end]
    #c = wavelet(Morlet(π/2), Q = 12, β = 1, s = 32, extraOctaves = 4 )
    #c = wavelet(Morlet(π/2),β=200,Q=30,s=32,extraOctaves=-8)
    c = wavelet(Morlet(),β=2)
    freqs = getMeanFreq(computeWavelets(n, c)[1])
    #a = cwt(d,c)
    t = range(0,n/100,length=n)
    yt = sin.(2π * 2 .*t)
    a = cwt(yt,c)
    f=heatmap(t,freqs,abs.(a))
    save("figures/cwts/cwt_$(rand(1)[])_.pdf",f, pdf_version="1.4")
    return(a,freqs)
end
function getcwt_GeneralizedMorseWavelets(d)
    k=0
    a=5
    u=512
    β=1
    γ=3
    N=length(d)
    normalization=:L2
    J=8
    Q=4
    wmin=0 # Minimum frequency peak allowed
    wmax=pi # Maximum frequency peak allowed
    normalization=:peak # Wavelet frequency peak normalized to 1
    g_params=gmw_grid(β,γ,J,Q,wmin,wmax) # Get the parameters of GMW bank, returns params in the form [a,u,β,γ]
    convl(x,g) = irfft(rfft(x) .* g,N) # For simplicity here we only compute the real part of the continuous wavelet transform
    get_gmw(g_p) = gmw(0,g_p...,N,normalization)
    x_cwt = [ convl(d,get_gmw(g_p)) for g_p in g_params] # Continous Wavelet transform
    a = hcat(x_cwt...)
    freqs = hcat(g_params...)[1,:]
    return(a,freqs)
end
makedf(p,m::Mocapdata) = DataFrame(p',mname2mname3d(m))
makedf(p,m::Normdata) = DataFrame(p',m.markerName)
mname2mname3d(m::Mocapdata) = vcat(map(x->x .* ["_x","_y","_z"],m.markerName)...)
scramblephases(f::Vector) = real(ifft(abs.(fft(f)).*exp.(im*angle.(fft(rand(size(f)...))))));
