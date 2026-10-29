    struct Mocap
        meta::Dict
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
        meta::Dict
        times::DataFrame
        timederOrder::Int
        conn::Matrix{Int}
    end
function mcread(fname)::Mocapdata
    lines::Vector{String} = readlines(fname)
    flag_from_header, header_ind, meta = get_prelude(lines)
    df = get_mocap_data(lines,header_ind::Int64)
    m = Mocap(meta,df)

    flag = :SOLVER in keys(meta) ? "Theia3D" : flag_from_header

    mt = Mocapdata("MoCap data",fname,get_nframes(m),get_nMarkers(m,lines,flag),get_framerate(m),get_body_parts(m,lines,flag),get_position(m,flag),m.meta,get_times(m,flag),0,makeConn(m,lines,flag))
    return mt
end
find_header(x::Vector{String}, y::String) = findfirst(contains(y),x)::Union{Int64,Nothing}
function get_prelude(lines::Vector{String})
    trajheader = find_header(lines, "TRAJECTORY_TYPES")
    frameheader = find_header(lines, "Frame")

    if !isnothing(trajheader)
        return "TRAJECTORY_TYPES", trajheader,
               get_metadata(lines, trajheader - 2)
    elseif !isnothing(frameheader)
        return "Frame", frameheader,
               get_metadata(lines, frameheader - 1)
    else
        error("No mocap data found")
    end
end
function get_metadata(lines::Vector{String},header_ind::Int)
    meta_unparsed = lines[1:header_ind]
    meta_split = [String.(row) for row in split.(meta_unparsed,"\t")]
    return Dict{Symbol,String}(
        Symbol(first(row)) => last(row)
        for row in meta_split
    )
end
get_nframes(m) = nrow(m.data)
function get_mocap_data(lines,header_ind)
    table_text = join(lines[header_ind:end], "\n")
    df = if any(occursin.("TRAJECTORY_TYPES", lines))
        CSV.read(IOBuffer(table_text), DataFrame; delim='\t', header=false, skipto=2)
    else
        CSV.read(IOBuffer(table_text), DataFrame; delim='\t')
    end
    return df
end
    function find_position_logical(m::Mocap,flag)
        n = names(m.data)
        if flag == "Theia3D"
            any([names(m.data) .== ["X" "Y" "Z"] occursin.(["X_" "Y_" "Z_"],n)],dims=2) .& .!(find_quaternions_logical(m)) # Will fail if a body part is labelled "X_Head" or "Z"
        else
            any(occursin.(["X" "Y" "Z"],n),dims=2);
        end
    end
    function find_position_inds(m::Mocap,flag)
        if flag == "Theia3D"
            map((x) -> x[1], findall(find_position_logical(m,flag)))
        elseif flag == "Frame"
            map((x) -> x[1], findall(find_position_logical(m,flag)))
        end
    end
    function get_others(m::Mocap,flag)
        if flag == "Theia3D"
            m.data[:,Not([find_position_inds(m,flag);find_quaternion_inds(m)])]# time, frame, body part names
        else
            m.data[:,Not(find_position_inds(m,flag))]# time, frame, body part names
        end
    end
    function get_body_parts(m::Mocap,lines,flag)
        if flag == "Theia3D"
            names(select(get_others(m,flag), Not(names(get_others(m,flag))[occursin.("clavicle", names(get_others(m,flag)))])))[3:end]
        elseif flag == "Frame"
            names(get_position(m,flag))
        elseif flag == "TRAJECTORY_TYPES"
            map(String,split(lines[10],'\t')[2:end])
        end
    end
    function get_position(m::Mocap,flag)
        if flag == "Theia3D"
            m.data[:,setdiff(find_position_inds(m,flag), vec(find_clavicle_pos_inds(m)))]
        elseif flag == "Frames"
            m.data[:,find_position_inds(m,flag)]
        else
            m.data
        end
    end
find_quaternions_logical(m) = any(occursin.(["QX" "QY" "QZ" "QW"],names(m.data)),dims=2)
        find_quaternion_inds(m) = map((x) -> x[1], findall(find_quaternions_logical(m)))
        get_quaternions(m) = m.data[:,find_quaternion_inds(m)]
        # we remove clavicle pos data from theia because it is same as torso (not the case for its quaternions)
        find_clavicle_name_inds(m) = findall(occursin.("clavicle",names(m.data)))
        find_clavicle_pos_inds(m) = hcat(map(x -> x .+ [1 2 3], find_clavicle_name_inds(m))...)
function makeConn(m,lines,flag)
    if flag == "Theia3D"
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
        conn = zeros(Int,get_nMarkers(m,lines,flag),2)
    end
    return conn
end
    get_framerate(m) = parse(Int,m.meta[:FREQUENCY])
    function get_times(m,flag)
        if flag == "Theia3D" ||  flag == "Frames"
            m.data[:,1:2] # Assumes "Time" and "Frame" always are the first two data columns
        elseif flag == "TRAJECTORY_TYPES"
            get_times_s(m) = (collect(1:size(m.data,1)).-1)./get_framerate(m)
            DataFrame(Frame=1:size(m.data,1),Time=get_times_s(m))
        end
    end
    get_nMarkers(m,lines,flag) = length(get_body_parts(m,lines,flag))
