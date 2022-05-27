#######################################################################
# Exceptions, Errors, Error processing
#######################################################################

abstract type JuliaPkgDownloaderException <: Exception end

#--------------------------------------------------
# Reading projects info
#--------------------------------------------------

struct PkgInfoBadFormat <: JuliaPkgDownloaderException
    pkgData :: Vector
end

struct PkgInfoInconsistentFormat <: JuliaPkgDownloaderException
    pkgData :: Vector
end
