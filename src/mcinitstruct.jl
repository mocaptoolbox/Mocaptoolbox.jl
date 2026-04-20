function mcinitstruct(df::DataFrame,fname::String,freq::Int,timederOrder::Int)
    times = DataFrame(Time=df[:,1])
    df = df[:,2:end]
    nframes = size(df,1)
    nmarkers = size(df,2)
    conn = zeros(Int,nmarkers,2)
    bp = string.(1:length(nmarkers))
    meta = ["no","metadata"]
    mt = Mocapdata("Norm data",fname,nframes,nmarkers,freq,bp,df,meta,times,timederOrder,conn)
end
