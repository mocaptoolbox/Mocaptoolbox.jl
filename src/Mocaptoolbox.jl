module Mocaptoolbox

using CSV, DataFrames, GLMakie, SavitzkyGolay, DataInterpolations, Statistics, NaNStatistics, LinearAlgebra, Distances, Rotations, Quaternions, FFMPEG, StaticArrays
# StaticArrays and Quaternions not currently being used!

import Base: *

export mcread
include("mcread.jl")

export mcreadfolder
include("mcreadfolder.jl")

export mcnorm
include("mcnorm.jl")

export mcplotframe
include("mcplotframe.jl")

export mcanimate
include("mcanimate.jl")

export mcmerge
include("mcmerge.jl")

export mcsplit
include("mcsplit.jl")

export mctimeder
include("mctimeder.jl")

export mcresample
include("mcresample.jl")

export mctrim
include("mctrim.jl")

export mcgetmarker
include("mcgetmarker.jl")

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

export hist
include("hist.jl")

export mcvel2local
include("mcvel2local.jl")

export mcorientation
include("mcorientation.jl")

export mccumdist
include("mccumdist.jl")

export mcinterpersonaldist
include("mcinterpersonaldist.jl")

export mcrejectoutliers
include("mcrejectoutliers.jl")

export mcrms
include("mcrms.jl")

export mcdropgaps
include("mcdropgaps.jl")

export mcrepairtheiadyad
include("mcrepairtheiadyad.jl")

export mcrotate
include("mcrotate.jl")

export mctranslate
include("mctranslate.jl")

export mccat
include("mccat.jl")

export mcrotatedyad
include("mcrotatedyad.jl")

export mcmissing
include("mcmissing.jl")

end
