using DataFrames
using CSV
using Colors
using Plots
gr()

const WCP_x = 448175.70093339786
const WCP_y = 4417804.258708443

# Plots.jl で円を描く関数
function circleShape(h, k, r)
    theta = LinRange(0, 2 * pi, 500)
    h .+ r * sin.(theta), k .+ r * cos.(theta)
end

function main(; X=WCP_x, Y=WCP_y)
    df = CSV.File("./data/data_WCP500.csv") |> DataFrame

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
    scatter!(fig, [X], [Y], marker=:x, c=:red, label=nothing)
    savefig(fig, "figures/data.png")
end


function main_with_gf(; POIx=WCP_x, POIy=WCP_y)
    df = CSV.File("./data/data_WCP500.csv") |> DataFrame

    # unique user list
    unique_users = unique(df.user)

    # 描画
    fig = plot(size=(500, 500))

    X, Y, R = computing_geofence()

    colors = distinguishable_colors(length(unique_users))
    for (i, user) in enumerate(unique_users)
        ci = colors[i]
        df_user = df[df.user.==user, :]
        scatter!(fig, df_user.x, df_user.y, ms=2, color=ci, alpha=0.25, label=nothing)
    end
    # POI
    scatter!(fig, [POIx], [POIy], marker=:x, c=:red, label=nothing)

    # ジオフェンス
    plot!(fig, [X], [Y], color=:red, marker=:+, markersize=10, label=nothing)
    plot!(fig, circleShape(X, Y, R), color=:black, seriestype=:shape, fillalpha=0.2, label=nothing, aspect_ratio=:equal)

    # 保存
    savefig(fig, "figures/data_with_gf.png")
end
