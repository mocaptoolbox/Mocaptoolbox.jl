"""
Scramble phases of mocap data
"""
function mcphasescramble(m::Union{Mocapdata,Normdata})
    m2 = deepcopy(m)
    p = phase_scramble(Matrix(m.data))
    m2.data = DataFrame(p,names(m.data))
    return m2
end
function mcphasescramble(fun::Function,m::Union{Mocapdata,Normdata}...;args=(),kwargs=(;),iter=100)
    r = Vector{Any}(undef,iter)
    @Threads.threads for k = 1:iter
        p = mcphasescramble.(m)
        r[k] = fun(p...,args...;kwargs...)
    end
    return r
end

phase_scramble(x) = real(ifft(abs.(fft(x, 1)) .* exp.(im .* angle.(fft(rand(size(x)...), 1))), 1))
