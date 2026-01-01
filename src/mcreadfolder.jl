"""
Read .tsv files in a folder and all its subfolders
"""
function mcreadfolder(location::String)
    r = []
    for (path, dirs, files) in walkdir(location)
        for file in files
            fullfile = joinpath(path,file)
            if file_extension(fullfile) == "tsv"
                push!(r,mcread(fullfile))
            end
        end
    end
    return r
end
file_extension(file::String) = file[findlast(==('.'), file)+1:end]
