module Mocaptoolbox

using CSV, DataFrames, GLMakie, SavitzkyGolay

import Base: *

export mcread
include("mcread.jl")

export mcanimate
include("mcanimate.jl")

export mcmerge
include("mcmerge.jl")

export mctimeder
include("mctimeder.jl")

end
