    mutable struct Mocap
        meta::Vector
        data::DataFrame
    end
    mutable struct Mocapdata
        type::String
        filename::String
        nFrames::Int
        nMarkers::Int
        freq::Int
        markerName::Union{String, Vector{String}}
        data::DataFrame
        meta::Vector
        times::DataFrame
        timederOrder::Int
        conn::Matrix{Int}
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
    m = Mocap(meta,df)

    if contains(meta[end][end],"Theia")
        find_quaternions_logical(m) = any(occursin.(["QX" "QY" "QZ" "QW"],names(m.data)),dims=2)
        find_quaternion_inds(m) = map((x) -> x[1], findall(find_quaternions_logical(m)))
        get_quaternions(m) = m.data[:,find_quaternion_inds(m)]
        no_quaternions(m) = m.data[:,Not(find_quaternion_inds(m))]
        # we remove clavicle pos data from theia because it is same as torso (not the case for its quaternions)
        find_clavicle_name_inds(m) = findall(occursin.("clavicle",names(m.data)))
        find_clavicle_pos_inds(m) = hcat(map(x -> x .+ [1 2 3], find_clavicle_name_inds(m))...)
        find_clavicle_logical(m) = in.(names(m.data), Ref(names(m.data)[find_clavicle_pos_inds(m)]))

    end
    function find_position_logical(m::Mocap)
        n = names(m.data)
        if contains(meta[end][end],"Theia")
            any([names(m.data) .== ["X" "Y" "Z"] occursin.(["X_" "Y_" "Z_"],n)],dims=2) .& .!(find_quaternions_logical(m)) # Will fail if a body part is labelled "X_Head" or "Z"
        else
            any(occursin.(["X" "Y" "Z"],n),dims=2);
        end
    end
    function find_position_inds(m::Mocap)
        if contains(meta[end][end],"Theia")
            map((x) -> x[1], findall(find_position_logical(m)))
        else
            map((x) -> x[1], findall(find_position_logical(m)))
        end
    end
    function get_others(m::Mocap)
        if contains(meta[end][end],"Theia")
            m.data[:,Not([find_position_inds(m);find_quaternion_inds(m)])]# time, frame, body part names

        else
            m.data[:,Not(find_position_inds(m))]# time, frame, body part names
        end
    end
    function get_body_parts(m::Mocap)
        if contains(meta[end][end],"Theia")
            names(select(get_others(m), Not(names(get_others(m))[occursin.("clavicle", names(get_others(m)))])))[3:end]
        else
            names(get_position(m))
        end
    end
    function get_position(m::Mocap)
                if contains(meta[end][end],"Theia")
                    m.data[:,setdiff(find_position_inds(m), vec(find_clavicle_pos_inds(m)))]
                else
                    m.data[:,find_position_inds(m)]
                end
    end
    get_nMarkers(m) = length(get_body_parts(m))
    function makeConn()
        if contains(meta[end][end],"Theia")
        conn = [1 2
                1 6
                1 18
                2 3
                3 4
                4 5
                6 7
                7 8
                8 9
                10 11
                10 14
                10 17
                10 18
                11 12
                12 13
                14 15
                15 16]
        else
            conn = zeros(Int,get_nMarkers(m),2)
        end
    end

    get_position(m) = m.data[:,setdiff(find_position_inds(m), vec(find_clavicle_pos_inds(m)))]
    get_times(m) = m.data[:,1:2] # Assumes "Time" and "Frame" always are the first two data columns
    get_nframes(m) = nrow(m.data)
    get_framerate(m) = parse(Int,m.meta[map(x -> x[1], m.meta) .== "FREQUENCY"][1][2])
    mt = Mocapdata("MoCap data",fname,get_nframes(m),get_nMarkers(m),get_framerate(m),get_body_parts(m),get_position(m),m.meta,get_times(m),0,makeConn())
    return mt
end
