#######################################################################
# Downloading git repositories (with Julia packages)
###############################
# 
# Designed to work in distributed manner, on multiple processess
#######################################################################

#--------------------------------------------------
# Constants
#--------------------------------------------------

const GIT_EXT = ".git"
const GIT_EXT_LEN = length(GIT_EXT)

# TODO: make sure that version SHA is always there
# Cloning only the main branch to save space on disk
const GIT_CLONE_CMD = `git clone --single-branch`

# Checking out a commit
const GIT_CHECKOUT_CMD = `git checkout`

# Julia package server
const JULIA_PKG_SERVER = "https://pkg.julialang.org/package"

# Information about packages from the General Registry
# (needed for extracting SHAs of package versions)
const PKGS_REGISTRY = Pkg.Registry.reachable_registries()[1].pkgs

# https://github.com/scheinerman/Multisets.jl/archive/refs/tags/v0.4.2.zip
# https://github.com/scheinerman/Multisets.jl.git

# https://github.com/scheinerman/Multisets.jl.git
# https://github.com/scheinerman/Multisets.jl/archive/refs/heads/master.zip

# https://gitlab.com/braneproject/Bitcoin.jl/-/tree/v0.1.12
# https://gitlab.com/braneproject/Bitcoin.jl.git
# https://gitlab.com/braneproject/Bitcoin.jl/-/archive/v0.1.12/Bitcoin.jl-v0.1.12.zip

# https://pkg.julialang.org/package/$uuid/$tree

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Processing a list of packages
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#--------------------------------------------------
# Cloning all repos
#--------------------------------------------------

#--------------------------------------------------
# Reading CSV with projects info
#--------------------------------------------------

"""
    StringFileName → Pair{Bool, Vector{GitRepo, UUID, [Version]}}
Reads `pkgListFile` with package info, filters out empty lines,
and returns `<versions provided> => <list of pkg info>`

Expected format for each package line:
- git repo
- UUID
- [version] -- optional, has to be either absent or present for all packages
"""
readPkgsInfo(pkgListFile :: String) :: Pair{Bool, Vector} = begin
    pkgInfos = map(pkg -> split(pkg, ","), readlines(pkgListFile))
    # `split("", ",") == [""]` => vectors are not empty
    dataSize = 0
    # filters empty lines and throws an error if data format is bad
    hasPkgData(pkgData) = begin
        # filter out empty lines
        length(pkgData) == 1 && isempty(pkgData[1]) && return false
        # check for git repos
        isGitRepo(pkgData[1]) || throw(PkgInfoBadFormat(pkgData))
        # make sure all lines have the same format
        dataSize == 0 || dataSize == length(pkgData) ||
            throw(PkgInfoInconsistentFormat(pkgData))
        dataSize == 0 && (dataSize = length(pkgData))
        (2 <= dataSize <= 3) || throw(PkgInfoBadFormat(pkgData))
        true # if got here, the data looks good
    end
    pkgInfos = filter(hasPkgData, pkgInfos)
    (dataSize == 3) => pkgInfos
end


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Cloning/downloading a single repo
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

"""
    (StringGitRepo, StringUUID, StringDirPath; [StringSHA], [Bool]) → Int
Clones git repository `gitrepo` into `dest` if the repo folder in `dest`
does not yet exist.
- If `commit` is specified, checks it out.
- If `overwrite` is set to `true`, re-clones the repo.

Returns 1 if cloned (and checked out if needed) successfully, and 0 otherwise.

Note. Parameter `uuid` is for compatibility of the interface with `downloadtar`
"""
gitClone(
    gitrepo :: String, uuid :: String, dest :: String;
    commit  :: String = "", overwrite :: Bool = false
) :: Int = begin
    # transforms `https://github.com/<path>/<name>.git` into `<dest>/<name>`
    dpath = joinpath(dest, basename(gitrepo)[begin:end-GIT_EXT_LEN])
    # if the repo directory needs to be overwritten, remove it first
    overwrite && isdir(dpath) && rm(dpath; recursive=true)
    # clone only if the repo doesn't exist
    if !isdir(dpath)
        try
            runclone() = run(`$(GIT_CLONE_CMD) $(gitrepo)`)
            # clone to the proper destinatation
            cd(runclone, dest)  # cloned successfully
        catch e
            @error e ; return 0 # cloning failed
        end
    end
    # if version is specified, check it out
    if !isempty(commit)
        try
            runcheckout() = run(`$(GIT_CHECKOUT_CMD) $(commit)`)
            cd(runcheckout, dpath) ; 1 # checked out successfully
        catch e
            @error e ; 0 # checkout failed
        end
    else
        1 # nothing more to do
    end
end

downloadTar(
    gitrepo :: String, uuid :: String, dest :: String;
    commit :: String, overwrite :: Bool = false
) :: Int = begin
    pkgName = basename(gitrepo)[begin:end-GIT_EXT_LEN]
    dpath = joinpath(dest, pkgName)
    # if the repo directory needs to be overwritten, remove it first
    overwrite && isdir(dpath) && rm(dpath; recursive=true)
    # download and unpack tarball
    dtar = "$dpath.tar.gz"
    try
        downloadCompat("$JULIA_PKG_SERVER/$uuid/$commit", dtar)
        mkdir(dpath) # create a directory for untaring
        run(`tar -xzf $dtar -C $dpath`)
        1 # unpacked successfully
    catch e
        @error e ; 0 # downloading/unpacking failed
    end
end

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Aux
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

"""
    AbstractString → Bool
Checks if `link` looks like a git repository link
"""
isGitRepo(link :: AbstractString) :: Bool = endswith(link, GIT_EXT)

#=
    (String, String) → String
Returns SHA of the commit corresponding to the `version`
of the package with the given `uuid`
=#
getPkgVersionSHA(uuid :: String, version :: String) :: String = begin
    pkgEntry = PKGS_REGISTRY[Base.UUID(uuid)]
    pkgInfo  = Pkg.Registry.registry_info(pkgEntry)
    versionInfo = pkgInfo.version_info[VersionNumber(version)]
    string(versionInfo.git_tree_sha1)
end