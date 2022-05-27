#--------------------------------------------------
# Imports
#--------------------------------------------------

using JuliaPkgDownloader
using Test

using Main.JuliaPkgDownloader: readPkgsInfo
using Main.JuliaPkgDownloader: PkgInfoBadFormat, PkgInfoInconsistentFormat
using Main.JuliaPkgDownloader: gitClone, downloadTar
using Main.JuliaPkgDownloader: getPkgVersionSHA


#--------------------------------------------------
# Aux values and functions
#--------------------------------------------------

const TEST_FILES_DIR      = "test-files"
const TEST_FILES_DIR_PATH = joinpath(@__DIR__, TEST_FILES_DIR)

testFilePath(path :: String) = joinpath(TEST_FILES_DIR_PATH, path)

tryrm(path :: AbstractString) =
    try rm(path; recursive=true); catch err @warn(err) end

#--------------------------------------------------
# Tests
#--------------------------------------------------

@testset "JuliaPkgDownloader.jl :: reading pkgs file  " begin
    @test JuliaPkgDownloader.isGitRepo("https://github.com/fonsp/Pluto.jl.git")
    @test !JuliaPkgDownloader.isGitRepo("https://github.com/git")

    @test readPkgsInfo(testFilePath("3-top-pkgs.txt")) == (true => [
        ["https://github.com/fonsp/Pluto.jl.git","c3e4b0f8-55cb-11ea-2926-15256bba5781","0.19.5"],
        ["https://github.com/FluxML/Flux.jl.git","587475ba-b771-5e3f-ad9e-33799f191a9c","0.13.1"],
        ["https://github.com/JuliaLang/IJulia.jl.git","7073ff75-c697-5162-941a-fcdaad2a7d2a","1.23.3"]
    ])
    @test readPkgsInfo(testFilePath("3-top-pkgs-no-version.txt")) == (false => [
        ["https://github.com/fonsp/Pluto.jl.git","c3e4b0f8-55cb-11ea-2926-15256bba5781"],
        ["https://github.com/FluxML/Flux.jl.git","587475ba-b771-5e3f-ad9e-33799f191a9c"],
        ["https://github.com/JuliaLang/IJulia.jl.git","7073ff75-c697-5162-941a-fcdaad2a7d2a"]
    ])
    @test readPkgsInfo(testFilePath("5-pkgs-empty.txt")) == (true => [
        ["https://github.com/JuliaLang/IJulia.jl.git","7073ff75-c697-5162-941a-fcdaad2a7d2a","1.23.3"],
        ["https://github.com/SciML/DifferentialEquations.jl.git","0c46a032-eb83-5123-abaf-570d42b7fbaa","7.1.0"],
        ["https://github.com/GiovineItalia/Gadfly.jl.git","c91e804a-d5a3-530f-b6f0-dfbca275c004","1.3.4"],
        ["https://github.com/GenieFramework/Genie.jl.git","c43c736e-a2d1-11e8-161f-af95117fbd1e","4.18.0"],
        ["https://github.com/JuliaPlots/Makie.jl.git","20f20a25-4f0e-4fdf-b5d1-57303727442b","0.3.1"]
    ])
    @test readPkgsInfo(testFilePath("empty.txt")) == (false => [])

    @test_throws PkgInfoBadFormat readPkgsInfo(testFilePath("bad-format-1.txt"))
    @test_throws PkgInfoBadFormat readPkgsInfo(testFilePath("bad-format-2.txt"))
    @test_throws PkgInfoBadFormat readPkgsInfo(testFilePath("bad-format-3.txt"))
    @test_throws PkgInfoInconsistentFormat readPkgsInfo(testFilePath("inconsistent-format.txt"))
end

@testset "JuliaPkgDownloader.jl :: cloning git repo   " begin
    gitClone(
        "https://github.com/korsbo/Latexify.jl.git", "23fbe1c1-3f47-55db-b15f-69d7ec21a316",
        TEST_FILES_DIR_PATH)
    dname1 = testFilePath("Latexify.jl")
    @test isdir(dname1)
    tryrm(dname1)

    #23fbe1c1-3f47-55db-b15f-69d7ec21a316,0.15.15
    #=
    gitClone(
        "https://github.com/jump-dev/JuMP.jl.git", "076af6c-e467-56ae-b986-b466b2749572",
        TEST_FILES_DIR_PATH;
        commit="84c1cf8bec4729b8b2ef4dfc4e1db1b892ad0d30")
    dname2 = testFilePath("JuMP.jl")
    @test isdir(dname2)
    =#

    downloadTar("https://github.com/jump-dev/JuMP.jl.git", "4076af6c-e467-56ae-b986-b466b2749572",
        TEST_FILES_DIR_PATH;
        commit="936e7ebf6c84f0c0202b83bb22461f4ebc5c9969")
    dname3 = testFilePath("JuMP.jl")
    @test isdir(dname2)
    tryrm(dname2)
    tryrm("$dname2.tar.gz")
end

@testset "JuliaPkgDownloader.jl :: getting package SHA" begin
    # JuMP
    @test getPkgVersionSHA("4076af6c-e467-56ae-b986-b466b2749572", "0.21.2") ==
        "84c1cf8bec4729b8b2ef4dfc4e1db1b892ad0d30"
    @test getPkgVersionSHA("4076af6c-e467-56ae-b986-b466b2749572", "1.0.0") ==
        "936e7ebf6c84f0c0202b83bb22461f4ebc5c9969"
end

@testset "JuliaPkgDownloader.jl" begin
    # Write your tests here.
end
