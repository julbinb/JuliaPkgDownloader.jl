#######################################################################
# Utils
#
# ASSUMPTION: the package defines variable `VERBOSE`
#######################################################################

include("equality.jl")

"If verbose, prints information `info`"
macro status(info)
    :(if VERBOSE ; @info($(esc(info))) end)
end
