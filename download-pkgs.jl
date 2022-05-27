#!/usr/bin/env julia

#**********************************************************************
# Script for downloading Julia packages
#**********************************************************************
# Downloads packages of the given versions
#   listed in the given file to the given directory.
# Default values: pkgs.txt and . (current directory)
#
# If Julia is launched in parallel mode, clones in parallel.
#
# Usage:
#
#   $ julia [-p N] download-pkgs.jl [-s <file>] [-d <folder>] [-r]
#
# File <file> should list package data in each line:
# - name
# - uuid
# version
#**********************************************************************

#--------------------------------------------------
# Imports
#--------------------------------------------------

using JuliaPkgDownloader
using ArgParse

#--------------------------------------------------
# Command Line Arguments
#--------------------------------------------------

# Parses arguments to [clone] routine (run with -h flag for more details)
function parse_clone_cmd()
    s = ArgParseSettings()
    s.description = """
    Downloads Julia packages listed in SRC to DEST.
    If Julia is launched in parallel mode (-p N), downloads in parallel.
    """
    @add_arg_table! s begin
        "--src", "-s"
            help = "file with packages information (name, uuid, version)"
            arg_type = String
            default = "pkgs.txt"
        "--dest", "-d"
            help = "directory to download packages"
            arg_type = String
            default = "./"
        "--overwrite", "-r"
            help = "if set, overwrites existing directories"
            action = :store_true
    end
    argDict = parse_args(s)
    (argDict["src"], argDict["dest"], argDict["overwrite"])
end

#--------------------------------------------------
# Main
#--------------------------------------------------

# Runs the clone command
(downloaded, total) = downloadAllPkgs(parse_clone_cmd()...)
@info "Successfully processed $(downloaded)/$(total)"
