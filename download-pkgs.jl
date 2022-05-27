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

using Distributed
using ArgParse
@everywhere using JuliaPkgDownloader

#--------------------------------------------------
# Command Line Arguments
#--------------------------------------------------

# Parses arguments to [clone] routine (run with -h flag for more details)
function parse_download_cmd()
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
        "--noverbose", "-q"
            help = "if set, intermediate processing information is not printed"
            action = :store_true
    end
    argDict = parse_args(s)
    ((argDict["src"], argDict["dest"], argDict["overwrite"]), argDict["noverbose"])
end

#--------------------------------------------------
# Main
#--------------------------------------------------

@info "Initiating packages downloading..."
(args, noverbose) = parse_download_cmd()
@everywhere JuliaPkgDownloader.setVerbose(!$noverbose)
(downloaded, total) = downloadAllPkgs(args...)
@info "Successfully processed $(downloaded)/$(total) packages"
