using DataFrames
using CSV
using Plots
gr()

const WCP_x = 448175.70093339786
const WCP_y = 4417804.258708443

include("../geofence.jl")

function circleShape(h, k, r)
    theta = LinRange(0, 2 * pi, 500)
    h .+ r * sin.(theta), k .+ r * cos.(theta)
end

if abspath(PROGRAM_FILE) == @__FILE__
    @info "Running $(PROGRAM_FILE)"
    gfs = Tuple{Float64,Float64,Float64}[]
    list = [300, 800, 1300, 1800, 2500]
    for mu in list
        gfml = computing_geofence(; μ=mu)
        push!(gfs, gfml)
    end

    # visualize seq. of Circulars
    data = "./data/data_WCP500.csv"
    df = CSV.File(data) |> DataFrame

    # unique user list
    unique_users = unique(df.user)

    # 描画
    fig = plot(size=(500, 500))

    colors = distinguishable_colors(length(unique_users))
    for (i, user) in enumerate(unique_users)
        ci = colors[i]
        df_user = df[df.user.==user, :]
        scatter!(fig, df_user.x, df_user.y, ms=2, color=ci, alpha=0.25, label=nothing)
    end

    # POI
    scatter!(fig, [WCP_x], [WCP_y], marker=:x, c=:red, label=nothing)
    colors = distinguishable_colors(length(gfs))
    for (i, (X, Y, R)) in enumerate(gfs)
        plot!(fig, circleShape(X, Y, R),
            color=colors[i],
            seriestype=:shape, fillalpha=0.15,
            label="$(list[i])", aspect_ratio=:equal)
    end

    # 保存
    savefig(fig, "figures/data_with_gf_multi_mu.png")
end