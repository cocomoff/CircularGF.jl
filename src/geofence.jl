using Metaheuristics
using DataFrames
using CSV

const WCP_x = 448175.70093339786
const WCP_y = 4417804.258708443

function computing_geofence(data="./data/data_WCP500.csv"; POIx=WCP_x, POIy=WCP_y, μ=2000, crlimit=0.5)
    # データをユーザごとに分割する
    df = CSV.File("./data/data_WCP500.csv") |> DataFrame
    unique_users = unique(df.user)
    list_df = [df[df.user .== user, :] for user in unique_users]

    function f(x, y, r)
        term1 = sqrt((x - WCP_x)^2 + (y - WCP_y)^2)
        term2 = r
        term3 = abs(term1 - r)
        return (term1 + term2 + term3) / 2
    end


    # カバー率と思っている量
    function cr(x, y, r, data)
        counter = 0
        for df in data
            if sum(((df.x .- x) .^ 2 .+ (df.y .- y) .^ 2) .<= r^2) > 0
                counter += 1
            end
        end
        counter / length(data)
    end


    # ここに元データ (GPSのDataFrames) が入っている。
    # お行儀がまったく良くなさそうな実装!!!!
    function g(x, y, r; data=list_df)
        μ * max(0, crlimit - cr(x, y, r, data))
    end

    # i = (x, y, r) を3次元ベクトルvとして思う
    fitness(v) = f(v[1], v[2], v[3]) + g(v[1], v[2], v[3])


    # ジオフェンス計算
    # 何も設定していないECA()でとりあえずfitnessを最適化する
    bounds = [POIx - 1000 POIx + 1000; POIy - 1000 POIy + 1000; 100 500]
    result = optimize(fitness, bounds, ECA())
    X, Y, R = minimizer(result)
    @info "X=$X, Y=$Y, R=$R"
    return X, Y, R
end