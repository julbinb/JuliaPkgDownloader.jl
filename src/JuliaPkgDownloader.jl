module JuliaPkgDownloader

#--------------------------------------------------
# Exports
#--------------------------------------------------

export downloadAllPkgs

#--------------------------------------------------
# Imports
#--------------------------------------------------

using Distributed
using Pkg

# Starting with Julia 1.6, `Base.download` is deprecated
# Package `Downloads` is available starting with Julia 1.3
@static if VERSION >= v"1.3"
    using Downloads
    downloadCompat = Downloads.download
else
    downloadCompat = download
end

#--------------------------------------------------
# Files
#--------------------------------------------------

include("common/errors.jl")
include("utils/utils.jl")
include("lib.jl")

#--------------------------------------------------
# Additional code
#--------------------------------------------------

"Flag responsible for printing status info"
VERBOSE = true

setVerbose(verbose :: Bool) = begin
    global VERBOSE = verbose
end

end # module 
