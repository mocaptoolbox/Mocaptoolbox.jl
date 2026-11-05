"""
Fill with zeros the other two dimensions.
"""
function mczeros(m::Union{Mocapdata,Normdata};comp=1)
    notcomp = setdiff(1:3,comp)
    m2 = deepcopy(m)
    m2.data[:,notcomp[1]:3:end] = zeros(size(m2.data[:,notcomp[1]:3:end]))
    m2.data[:,notcomp[2]:3:end] = zeros(size(m2.data[:,notcomp[2]:3:end]))
    return m2
end
