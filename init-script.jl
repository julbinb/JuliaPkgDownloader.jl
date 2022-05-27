#!/usr/bin/env julia

#######################################################################
# Initializes global environment with the current package
#######################################################################

using Pkg
Pkg.develop(path=@__DIR__)
