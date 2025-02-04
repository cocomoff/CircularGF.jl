using Metaheuristics
using DataFrames
using CSV

const WCP_x = 448175.70093339786
const WCP_y = 4417804.258708443

function computing_geofence(data="./data/data_WCP500.csv"; POIx=WCP_x, POIy=WCP_y)
    # データをユーザごとに分割する
    df = CSV.File(data) |> DataFrame
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


    # eval
    function eval(v)
        # TODO: 500 -> read from the pre-processed data
        f1 = f(v[1], v[2], v[3]) / (2 * 500)
        g1 = cr(v[1], v[2], v[3], list_df) / length(unique_users)

        # constraints
        gx = [0.0] # inequality constraints
        hx = [0.0] # equality constraints
        return [f1, g1], gx, hx
    end

    bounds = [POIx - 1000 POIx + 1000; POIy - 1000 POIy + 1000; 100 500]
    result = optimize(eval, bounds, NSGA2())
    X, Y, R = minimizer(result)
    @info "X=$X, Y=$Y, R=$R"
    return X, Y, R
end