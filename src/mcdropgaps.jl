"""
mcdropgaps removes frames containing at least one gap
"""
function mcdropgaps(m::Union{Mocapdata,Normdata};timetable = "reset")
    mask = .!any(isnan.(Matrix(m.data)),dims=2)[:]
    x = Matrix(m.data)[mask,:]
    if timetable == "reset"
        times = m.times[1:sum(mask),:]
    elseif timetable == "keep" # jagged
        times = m.times[mask,:]
    end
    res = deepcopy(m)
    res.data = DataFrame(x,names(m.data))
    res.times = times
    return res
end
