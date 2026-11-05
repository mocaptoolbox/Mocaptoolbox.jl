function mcmirror(m::Mocapdata;comp=1)
    m.timederOrder == 0 && @warn "This function only negates the component (does not swap body parts) so it is meant for velocity or higher order derivatives only"
    m2 = deepcopy(m)
    m2.data[:,comp:3:end] .*= -1
    return m2
end
