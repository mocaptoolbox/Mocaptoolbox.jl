module Mocaptoolbox

using CSV, DataFrames, GLMakie, SavitzkyGolay, DataInterpolations, Statistics, LinearAlgebra

import Base: *

export mcread
include("mcread.jl")

export mcplotframe
include("mcplotframe.jl")

export mcanimate
include("mcanimate.jl")

export mcmerge
include("mcmerge.jl")

export mctimeder
include("mctimeder.jl")

export mcresample
include("mcresample.jl")

export mctrim
include("mctrim.jl")

export mcgetmarker
include("mcgetmarker.jl")

export mcnorm
include("mcnorm.jl")

export mccorr
include("mccorr.jl")

export mccomplexity
include("mccomplexity.jl")

export mcfillgaps
include("mcfillgaps.jl")

export mcfluidity
include("mcfluidity.jl")

export plot
include("plot.jl")

export heatmap
include("heatmap.jl")

end
