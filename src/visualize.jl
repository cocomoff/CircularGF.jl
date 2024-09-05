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

function main(data="./data/data_WCP500.csv"; X=WCP_x, Y=WCP_y, normalize=false)
    df = CSV.File(data) |> DataFrame

    if normalize
        # (x, y) を[0, 1] に変換する
        max_x, min_x = maximum(df.x), minimum(df.x)
        max_y, min_y = maximum(df.y), minimum(df.y)
        df[:, "norm_x"] = (df.x .- min_x) ./ (max_x - min_x)
        df[:, "norm_y"] = (df.y .- min_y) ./ (max_y - min_y)
    end


    # unique user list
    unique_users = unique(df.user)

    # 描画
    fig = plot(size=(500, 500))


    colors = distinguishable_colors(length(unique_users))
    for (i, user) in enumerate(unique_users)
        ci = colors[i]
        df_user = df[df.user.==user, :]

        if normalize
            scatter!(fig, df_user.norm_x, df_user.norm_y, ms=2, color=ci, alpha=0.25, label=nothing)
        else
            scatter!(fig, df_user.x, df_user.y, ms=2, color=ci, alpha=0.25, label=nothing)
        end
    end
    if normalize
        scatter!(fig, [(X - min_x) / (max_x - min_x)], [(Y - min_y) / (max_y - min_y)], marker=:x, c=:red, label=nothing)
    else
        scatter!(fig, [X], [Y], marker=:x, c=:red, label=nothing)
    end
    suffix = normalize ? "_norm" : ""
    savefig(fig, "figures/data$(suffix).png")
end


function main_with_gf(data="./data/data_WCP500.csv", obase="./figures/data_with_gf"; POIx=WCP_x, POIy=WCP_y, normalize=false)
    df = CSV.File(data) |> DataFrame
    max_x, min_x = maximum(df.x), minimum(df.x)
    max_y, min_y = maximum(df.y), minimum(df.y)

    if normalize
        # (x, y) を[0, 1] に変換する    
        df[:, "norm_x"] = (df.x .- min_x) ./ (max_x - min_x)
        df[:, "norm_y"] = (df.y .- min_y) ./ (max_y - min_y)
    end


    # unique user list
    unique_users = unique(df.user)

    # 描画
    fig = plot(size=(500, 500))

    X, Y, R = computing_geofence(data; normalize=normalize)

    colors = distinguishable_colors(length(unique_users))
    for (i, user) in enumerate(unique_users)
        ci = colors[i]
        df_user = df[df.user.==user, :]
        if normalize
            # println(df_user.norm_x)
            scatter!(fig, df_user.norm_x, df_user.norm_y, ms=2, color=ci, alpha=0.25, label=nothing)
        else
            scatter!(fig, df_user.x, df_user.y, ms=2, color=ci, alpha=0.25, label=nothing)
        end
    end

    # POI
    if normalize
        scatter!(fig, [(POIx - min_x) / (max_x - min_x)], [(POIy - min_y) / (max_y - min_y)], marker=:x, c=:red, label=nothing)
    else
        scatter!(fig, [POIx], [POIy], marker=:x, c=:red, label=nothing)
    end

    # ジオフェンス
    plot!(fig, [X], [Y], color=:red, marker=:+, markersize=10, label=nothing)
    plot!(fig, circleShape(X, Y, R), color=:black, seriestype=:shape, fillalpha=0.2, label=nothing, aspect_ratio=:equal)

    # 保存
    suffix = normalize ? "_norm" : ""
    oname = "$(obase)$(suffix).png"
    savefig(fig, oname)
end


function main_with_gf_after(data="./data/data_WCP500.csv"; POIx=WCP_x, POIy=WCP_y, normalize=false)
    df = CSV.File(data) |> DataFrame
    max_x, min_x = maximum(df.x), minimum(df.x)
    max_y, min_y = maximum(df.y), minimum(df.y)
    dx = max_x - min_x
    dy = max_y - min_y

    if normalize
        # (x, y) を[0, 1] に変換する    
        df[:, "norm_x"] = (df.x .- min_x) ./ dx
        df[:, "norm_y"] = (df.y .- min_y) ./ dy
    end


    # unique user list
    unique_users = unique(df.user)

    # 描画
    fig = plot(size=(500, 500))

    X, Y, R = computing_geofence(data)

    colors = distinguishable_colors(length(unique_users))
    for (i, user) in enumerate(unique_users)
        ci = colors[i]
        df_user = df[df.user.==user, :]
        if normalize
            # println(df_user.norm_x)
            scatter!(fig, df_user.norm_x, df_user.norm_y, ms=2, color=ci, alpha=0.25, label=nothing)
        else
            scatter!(fig, df_user.x, df_user.y, ms=2, color=ci, alpha=0.25, label=nothing)
        end
    end

    # POI
    if normalize
        scatter!(fig, [(POIx - min_x) / dx], [(POIy - min_y) / dy], marker=:x, c=:red, label=nothing)
    else
        scatter!(fig, [POIx], [POIy], marker=:x, c=:red, label=nothing)
    end

    # normalized ジオフェンス
    # TODO: fix normalized eq.
    nX = (X - min_x) / dx
    nY = (Y - min_y) / dy
    # nR = R / sqrt(dx ^2 + dy ^ 2)
    nR = R / sqrt(min(dx ^ 2, dy ^ 2))
    @info "(X,Y,R)=($X,$Y,$R)"
    @info "norm (X,Y,R)=($nX,$nY,$nR)"
    plot!(fig, [nX], [nY], color=:red, marker=:+, markersize=10, label=nothing)
    plot!(fig, circleShape(nX, nY, nR), color=:black, seriestype=:shape, fillalpha=0.2, label=nothing, aspect_ratio=:equal)

    # 保存
    savefig(fig, "figures/data_with_gfa.png")
end