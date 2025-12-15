    mutable struct mocap
        meta::Vector
        data::DataFrame
    end
    mutable struct mocapdata
        type::String
        filename::String
        nFrames::Int
        freq::Int
        markerName::Vector{String}
        data::DataFrame
        meta::Vector
        times::DataFrame
        timederOrder::Int
    end
function mcread(fname)
    lines = readlines(fname)

    find_header(x::Vector, y::String) = findfirst(contains(y),x)
    header_ind = find_header(lines,"Frame")

    function get_metadata(lines,header_ind)
        meta_unparsed = lines[1:header_ind-1]
        meta = Vector{Tuple{String,String}}(undef, length(meta_unparsed))
        i = 1
        for line in meta_unparsed
            parts = split(line,'\t')
            key,value = parts[1], length(parts) > 1 ? parts[2] : ""
            meta[i] = key,value
            i += 1
        end
        return meta
    end
    meta = get_metadata(lines,header_ind)

    function get_mocap_data(header_ind)
        table_text = join(lines[header_ind:end], "\n")
        df = CSV.read(IOBuffer(table_text), DataFrame; delim='\t')
    end
    df = get_mocap_data(header_ind)


    m = mocap(meta,df)

    find_quaternions_logical(m) = any(occursin.(["QX" "QY" "QZ" "QW"],names(m.data)),dims=2)
    find_quaternion_inds(m) = map((x) -> x[1], findall(find_quaternions_logical(m)))
    get_quaternions(m) = m.data[:,find_quaternion_inds(m)]
    no_quaternions(m) = m.data[:,Not(find_quaternion_inds(m))]

    # Will fail if a body part is labelled "X_Head" or "Z"
    find_position_logical(m) = any([names(m.data) .== ["X" "Y" "Z"] occursin.(["X_" "Y_" "Z_"],names(m.data))],dims=2) .& .!(find_quaternions_logical(m))
    find_position_inds(m) = map((x) -> x[1], findall(find_position_logical(m)))
    get_position(m) = m.data[:,find_position_inds(m)]
    get_others(m) =  m.data[:,Not([find_position_inds(m);find_quaternion_inds(m)])]# time, frame, body part names
    get_body_parts(m) = names(get_others(m))[3:end] # Assumes "Time" and "Frame" always are the first two data columns
    get_times(m) = m.data[:,1:2] # Assumes "Time" and "Frame" always are the first two data columns
    get_nframes(m) = nrow(m.data)
    get_framerate(m) = parse(Int,m.meta[3][2])
    mt = mocapdata("MoCap data",fname,get_nframes(m),get_framerate(m),get_body_parts(m),get_position(m),m.meta,get_times(m),0)
    return mt
end
