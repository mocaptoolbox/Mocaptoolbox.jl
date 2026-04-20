function mcrmmarker(m::Mocapdata,mnum)
    x = mcgetmarker(m,setdiff(1:m.nMarkers,mnum))
end
