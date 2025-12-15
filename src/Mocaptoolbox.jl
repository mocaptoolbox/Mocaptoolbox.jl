module Mocaptoolbox

using CSV, DataFrames, GLMakie, SavitzkyGolay

import Base: *

export mcanimate
include("mcanimate.jl")

export mcread
include("mcread.jl")

export mcmerge
include("mcmerge.jl")

export mctimeder
include("mctimeder.jl")

end
