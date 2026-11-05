"""
Band pass filters data in a MoCap or norm structure using an FFT filter.

"""
function mcbandpass(m::Union{Mocapdata,Normdata},f1,f2;method=rect)
    m2 = deepcopy(m)
    mn = mean(Matrix(m2.data),dims=1)
    m2.data .-= mn
    m2.data = fftfilter(m2.data, m2.freq, f1, f2, method)
    m2.data .+= mn
    return m2
end

function gauss(x, μ, σ)
    return (1 / (σ * sqrt(2π))) .* exp.(-((x .- μ).^2) ./ (2 * σ^2))
end

"""
fftfilter(y, fs, minf, maxf, method="rect")

Non-causal bandpass filter based on the FFT.

# Arguments
- `y`: Signal vector or matrix. If a matrix, each column is filtered independently.
- `fs`: Sampling frequency.
- `minf`: Lower cutoff frequency.
- `maxf`: Upper cutoff frequency.
- `method`: `"rect"` for a rectangular frequency mask, or `"gauss"` for a
Gaussian frequency weighting.
"""
function fftfilter(y, fs, minf, maxf, method="rect")
    y = ndims(y) == 1 ? reshape(y, :, 1) : y
    y2 = similar(y)

    for k in axes(y, 2)
        z = fft(y[:, k])

        ff = (0:length(z)-1) ./ length(z)
        f = fs .* (ff .- round.(ff))

        if method == "gauss"
            meanf = 0.5 * (maxf + minf)
            sd = 0.5 * (maxf - minf)
            sc = gauss(abs.(f), meanf, sd)
            z .*= sc
        else
            # Frequencies to be removed
            z[abs.(f) .< minf .| (abs.(f) .> maxf)] .= 0
        end

        # `real` removes small numerical imaginary components
        y2[:, k] = real.(ifft(z))
    end

    return ndims(y) == 2 && size(y, 2) == 1 ? vec(y2) : y2
end
