    mutable struct Mocap
        meta::Vector{Tuple{String, String}}
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
        meta::Vector{Tuple{String, String}}
        times::DataFrame
        timederOrder::Int
        conn::Matrix{Int}
        quat::DataFrame
    end
function mcread(fname)
    lin = readlines(fname)
    if isa(find_header(lin,"TRAJECTORY_TYPES"),Int)
        flag = "TRAJECTORY_TYPES"
        header_ind = find_header(lin,flag)
        meta = get_metadata(lin,header_ind-2)
    elseif isa(find_header(lin,"Frame"),Int)
        flag = "Frame"
        header_ind = find_header(lin,flag)
        meta = get_metadata(lin,header_ind-1)
    end
    df = get_mocap_data(header_ind,lin)
    m = Mocap(meta,df)
    if contains(meta[end][end],"Theia3D")
        flag = "Theia3D"
    end
    mt = Mocapdata("MoCap data",fname,get_nframes(m),get_nMarkers(m,lin,flag),get_framerate(m),get_body_parts(m,lin,flag),get_position(m,flag),m.meta,get_times(m,flag),0,makeConn(m,lin,flag),get_quaternions(m,flag))
    return mt
end
find_header(x::Vector, y::String) = findfirst(contains(y),x)
function get_metadata(lin,header_ind)
    meta_unparsed = lin[1:header_ind]
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
function get_mocap_data(header_ind,lin)
    table_text = join(lin[header_ind:end], "\n")
    df = CSV.read(IOBuffer(table_text), DataFrame; delim='\t')
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
    map((x) -> x[1], findall(find_position_logical(m,flag)))
end
find_quaternions_logical(m) = any(occursin.(["QX" "QY" "QZ" "QW"],names(m.data)),dims=2)
find_quaternion_inds(m) = map((x) -> x[1], findall(find_quaternions_logical(m)))
get_quaternions(m) = m.data[:,find_quaternion_inds(m)]
no_quaternions(m) = m.data[:,Not(find_quaternion_inds(m))]
# we remove clavicle pos data from theia because it is same as torso (not the case for its quaternions)
find_clavicle_name_inds(m) = findall(occursin.("clavicle",names(m.data)))
find_clavicle_pos_inds(m) = hcat(map(x -> x .+ [1 2 3], find_clavicle_name_inds(m))...)
find_clavicle_quat_inds(m) = hcat(map(x -> x .+ [4 5 6 7], find_clavicle_name_inds(m))...)
function get_others(m::Mocap,flag)
    if flag == "Theia3D"
        m.data[:,Not([find_position_inds(m,flag);find_quaternion_inds(m)])]# time, frame, body part names
    else
        m.data[:,Not(find_position_inds(m,flag))]# time, frame, body part names
    end
end
function get_body_parts(m::Mocap,lin,flag)
    if flag == "Theia3D"
        names(select(get_others(m,flag), Not(names(get_others(m,flag))[occursin.("clavicle", names(get_others(m,flag)))])))[3:end]
    elseif flag == "Frame"
        names(get_position(m))
    elseif flag == "TRAJECTORY_TYPES"
        String.(split(lin[10],'\t')[2:end])
    end
end
function get_quaternions(m::Mocap,flag)
    if flag == "Theia3D"
        m.data[:,setdiff(find_quaternion_inds(m), vec(find_clavicle_quat_inds(m)))]
    elseif flag == "Frames"
        nothing
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
function makeConn(m,lin,flag)
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
        conn = zeros(Int,get_nMarkers(m,lin,flag),2)
    end
end
get_nMarkers(m,lin,flag) = length(get_body_parts(m,lin,flag))
get_nframes(m) = nrow(m.data)
get_framerate(m) = parse(Int,m.meta[map(x -> x[1], m.meta) .== "FREQUENCY"][1][2])
function get_times(m,flag)
    if flag == "Theia3D" ||  flag == "Frames"
        m.data[:,1:2] # Assumes "Time" and "Frame" always are the first two data columns
    elseif flag == "TRAJECTORY_TYPES"
        DataFrame(Frame=1:size(m.data,1),Time=get_times_s(m))
    end
end
get_times_s(m) = (collect(1:size(m.data,1)).-1)./get_framerate(m)
