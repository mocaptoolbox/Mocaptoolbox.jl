"""
    mctrim(m::Mocapdata, t1, t2; type="sec", timetable="reset")

Trim MoCap data to a specified time or frame interval.

# Arguments
- `m::Mocapdata`: Input MoCap data structure.
- `t1`: Start time or frame index.
- `t2`: End time or frame index.

# Keyword Arguments
- `type="sec"`:
  Determines how `t1` and `t2` are interpreted.
  - `"sec"`: `t1` and `t2` are given in seconds and converted to frame indices using `m.freq`.
  - `"frame"`: `t1` and `t2` are treated directly as frame indices.

- `timetable="reset"`:
  Controls how the time table is handled in the trimmed result.
  - `"reset"`: Frame and time values are reset so the first frame starts at zero.
  - `"keep"`: Original frame and time values are preserved.

# Returns
- `Mocapdata`: A trimmed MoCap struct containing:
  - Data restricted to frames `t1:t2`
  - Updated `times` table
  - Updated `nFrames` field

# Notes
- Frame indices are rounded when converting from seconds.

# Example
```julia
m2 = mctrim(m, 1.0, 3.5; type="sec", timetable="reset")
m3 = mctrim(m, 100, 300; type="frame", timetable="keep")
```
"""
function mctrim(m::Union{Mocapdata,Normdata},t1,t2;type="sec",timetable="reset")
    d1 = Matrix(m.data)
    tm = Matrix(m.times)
    if type == "sec"
        t1=round(m.freq * t1)+1;
        t2=round(m.freq * t2)+1;
    elseif type == "frame"
        nothing
    else
        error("type must be \"sec\" or \"frame\"")
    end
    d2 = d1[t1:t2,:]
    tm2 = tm[t1:t2,:]
    res = deepcopy(m)
    res.data = DataFrame(d2,names(m.data))
    if timetable == "reset"
        res.times = DataFrame(Frame=Int.(tm2[:,1].-tm2[1,1]), Time=tm2[:,2].-tm2[1,2])
    elseif timetable == "keep"
        res.times = DataFrame(Frame=Int.(tm2[:,1]), Time=tm2[:,2])
    else
        error("timetable must be \"reset\" or \"keep\"")
    end
    res.nFrames = size(res.data,1)
    return res
end
