struct Orderpar
    length
    angle
    directional
    directional_at_beats
    beats
    metriclevel
    bandpass
    mname
end
"""
`mcorderpar(m::Union{Mocapdata,Normdata},tempo::Real; t0::Real = 0, metricLevel::Real=1, bandpass::Bool=false,bwRatio::Float64=.4)::Orderpar`

Computes order parameter for each marker and dimension.
"""
function mcorderpar(m::Union{Mocapdata,Normdata},tempo::Real; t0::Real = 0, metricLevel::Real=1, bandpass::Bool=false,bwRatio::Float64=.4)::Orderpar
    m.timederOrder > 0 || error("Position data cannot be used. Use a time derivative")
    f0 = tempo/60 # beat frequency in hertz
    bandpass ? error("mcbandpass not yet implemented") : Nothing
    d = Matrix(m.data)
    durs = m.nFrames/m.freq;
    #dims = 1:size(d,2)/numel(m.markerName);
    shift = m.freq*t0;
    t = 0:1/m.freq:durs;
    t = t[1:end-1];
    x = cos.(2π*f0*t.-shift); #generate a cosine wave (or a shifted version of it) at a beat frequency that corresponds with the tempo
    ph = unwrap(angle.(hilbert(x)))
    BF = 1 / metricLevel;
    pha = unwrap(angle.(hilbert(d)),dims=1); # get analytic signal and then unwrapped phase
    mb = BF*durs*tempo/60; # number of beats
    BL = 60/(BF*tempo);# beat length in seconds for a given beat level
    beats=(0:mb)*BL; # beat location in seconds
    dph = BF*ph.-pha; # difference between unwrapped phase of cosine wave (scaled to target beat level) and unwrapped phase of data
    ser = FastInterpolations.Series(dph) # interpolate so as to get the unwrapped phase difference at each beat
    itp = cubic_interp(t,ser,extrap=ExtendExtrap())
    dphBeats = hcat(itp(beats)...)
    dirVecComp = cos.(dph)+im*sin.(dph); # directional data, expressed as complex numbers of unit magnitude
    dirVecRad = atan.(imag(dirVecComp),real(dirVecComp)); # directional data, in radians
    dphBeatsDirVecComp = cos.(dphBeats)+im*sin.(dphBeats); # directional data at (sub/super) beat locations, expressed as complex numbers of unit magnitude
    dphBeatsDirVecRad = atan.(imag(dphBeatsDirVecComp),real(dphBeatsDirVecComp)); # directional data at (sub/super) beat locations, in radians
    MRV = mean(dphBeatsDirVecComp,dims=1); # mean resultant vector of directional data
    MRVL = vec(abs.(MRV));
    MRVA = vec(angle.(MRV));
    return Orderpar(MRVL,MRVA,vec(dirVecRad),vec(dphBeatsDirVecRad),beats,metricLevel,bandpass,m.markerName)
end
"""
`mcorderpar(m::Union{Mocapdata,Normdata},tempo::Real,dim::Int64; t0::Real = 0, metricLevel::Real=1, bandpass::Bool=false,bwRatio::Float64=.4)::Orderpar`

Computes order parameter for a given marker and dimension. The result can be plotted as a polar plot using `plot()`.
"""
function mcorderpar(m::Union{Mocapdata,Normdata},tempo::Real,dim::Int64; t0::Real = 0, metricLevel::Real=1, bandpass::Bool=false,bwRatio::Float64=.4)::Orderpar
    m.timederOrder > 0 || error("Position data cannot be used. Use a time derivative")
    f0 = tempo/60 # beat frequency in hertz
    bandpass ? error("mcbandpass not yet implemented") : Nothing
    d = Matrix(m.data)[dim:3:end]
    durs = m.nFrames/m.freq;
    #dims = 1:size(d,2)/numel(m.markerName);
    shift = m.freq*t0;
    t = 0:1/m.freq:durs;
    t = t[1:end-1];
    x = cos.(2π*f0*t.-shift); #generate a cosine wave (or a shifted version of it) at a beat frequency that corresponds with the tempo
    ph = unwrap(angle.(hilbert(x)))
    BF = 1 / metricLevel;
    pha = unwrap(angle.(hilbert(d)),dims=1); # get analytic signal and then unwrapped phase
    mb = BF*durs*tempo/60; # number of beats
    BL = 60/(BF*tempo);# beat length in seconds for a given beat level
    beats=(0:mb)*BL; # beat location in seconds
    dph = BF*ph.-pha; # difference between unwrapped phase of cosine wave (scaled to target beat level) and unwrapped phase of data
    ser = FastInterpolations.Series(dph) # interpolate so as to get the unwrapped phase difference at each beat
    itp = cubic_interp(t,ser;extrap=ExtendExtrap())
    dphBeats = hcat(itp(beats)...)
    dirVecComp = cos.(dph)+im*sin.(dph); # directional data, expressed as complex numbers of unit magnitude
    dirVecRad = atan.(imag(dirVecComp),real(dirVecComp)); # directional data, in radians
    dphBeatsDirVecComp = cos.(dphBeats)+im*sin.(dphBeats); # directional data at (sub/super) beat locations, expressed as complex numbers of unit magnitude
    dphBeatsDirVecRad = atan.(imag(dphBeatsDirVecComp),real(dphBeatsDirVecComp)); # directional data at (sub/super) beat locations, in radians
    MRV = mean(dphBeatsDirVecComp,dims=1); # mean resultant vector of directional data
    MRVL = abs.(MRV)[];
    MRVA = angle.(MRV)[];
    return Orderpar(MRVL,MRVA,vec(dirVecRad),vec(dphBeatsDirVecRad),beats,metricLevel,bandpass,m.markerName)
end
