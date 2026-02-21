using Documenter
using PSSEModels

makedocs(
    sitename = "PSSEModels.jl",
    format = Documenter.HTML(),
    modules = [PSSEModels],
    warnonly = true,
    pages = [
        "Home" => "index.md",
        "Manual" => "manual.md",
        "Reference" => "reference.md",
    ]
)

# Documenter can also deploy docs to GitHub Pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
