
module Segregation

import Random
import OrderedCollections as OC

import Luxor as L

function params(;
                nrows = 25,
                ncols = 25,
                propRed = 0.4,
                propBlue = 0.4,
                threshold = 60.0,
                a = 20.0,
                d = 1.0)
    Dict(
        :nrows => nrows,
        :ncols => ncols,
        :propRed => propRed,
        :propBlue => propBlue,
        :threshold => threshold,
        :a => a,
        :d => d,
    )
end


"""
This is the initial grid.
People are distributed randomly across this grid.
"""
function initgrid(nrows, ncols, propred, propblue)
    numcells = nrows * ncols
    mat = Matrix{Symbol}(undef, nrows, ncols)
    mat[:] .= :E
    
    posns = [(r,c) for r = 1:nrows for c = 1:ncols]
    rndposns = Random.shuffle(posns)
    numred = (propred * numcells) |> floor |> Int
    numblue = (propblue * numcells) |> floor |> Int
    
    redposns = rndposns[1:numred]
    blueposns = rndposns[numred+1:numred+numblue]

    for posn in redposns
        mat[posn...] = :R
    end
    
    for posn in blueposns
        mat[posn...] = :B
    end

    return mat
end


function draw_grid(grid, filename)
    nrows, ncols = size(grid)
    # width, height, filename
    scale = 2
    L.Drawing(25 * scale * nrows, 25 * scale * ncols, filename)
    L.origin() ## reset origin to the center of the drawing
    tiles = L.Tiler(25 * scale * nrows, 25 * scale * ncols, nrows, ncols, margin=1)

    for (pos, n) in tiles
        row = div(n, ncols) + (rem(n, ncols) > 0 ? 1 : 0)
        col = n - ((row - 1) * ncols)
        L.sethue("gray")
        L.box(pos, tiles.tilewidth, tiles.tileheight, action=:stroke)
        persontype = grid[row, col]
        if persontype == :R
            L.sethue("lightsalmon")
        elseif persontype == :B
            L.sethue("steelblue")
        else
            L.sethue("white")
        end
        L.box(pos, tiles.tilewidth, tiles.tileheight, action=:fill)
        L.sethue("white")
        # L.textcentered(string((row, col)), pos + L.Point(0,5))
    end
    L.finish()
end

"""
Find neighboring positions
`posn` will be a (r,c) tuple.
"""
function neighboring_posns(posn, nrows, ncols)
    [(row,col) 
        for row in (posn[1]-1:posn[1]+1)
            for col in (posn[2]-1:posn[2]+1)
                if (!(row == posn[1] && col == posn[2]) &&
                    (1 <= row <= nrows) &&
                    (1 <= col <= ncols))
    ]
end

"""
We will return an ordered dictionary that we will reuse in every
iteration, instead of calculating this every time.
"""
function all_neighboring_posns(nrows, ncols)
    posns = [(r,c) for r = 1:nrows for c = 1:ncols]
    OC.OrderedDict(
        p => neighboring_posns(p, nrows, ncols) 
            for p in posns
    )
end


"""
Find proportion of the other type for a person currently in position `posn`
"""
function perc_other_type(posn, person_type, grid, all_neighbor_posns)
    ## get neighboring positions
    neighbor_posns = all_neighbor_posns[posn]
    ## get the number of other type in those posns
    pt = person_type 
    num_other_type = 0
    num_empty = 0
    for posn in neighbor_posns
        el = grid[posn...]
        if el != pt && el != :E
          num_other_type += 1  
        elseif el == :E
            num_empty += 1
        end
    end
    occupied_posns = length(neighbor_posns) - num_empty
    ## calc (number other type/number neighbors) * 100
    if occupied_posns > 0
        (num_other_type/occupied_posns) * 100
    else
        50.0
    end
end


"""
`pv` => param values
"""
function utility(posn, person_type, grid, all_neighbor_posns, pv)
    perc_other = perc_other_type(posn, person_type, grid, all_neighbor_posns)
    threshold = pv[:threshold]
    a = pv[:a]
    d = pv[:d]
    if perc_other > threshold
        return 0.0
    else
        return a + d * (50.0 - abs(perc_other - 50))
    end
end


"""
Return value: OC.OrderedDict (keys -> posns, values -> utilities)
Used for finding the best empty location to move to.
"""
function utilities_at_emptylocs(person_type, grid, all_neighbor_posns, pv)
    output = OC.OrderedDict{Tuple{Int64, Int64}, Float64}()
    nrows, ncols = size(grid)
    for row in 1:nrows  
        for col in 1:ncols
            if grid[row, col] == :E
                output[(row, col)] = 
                    utility((row, col),
                            person_type,
                            grid, 
                            all_neighbor_posns,
                            pv)
            end
        end
    end
    output
end


function find_best_loc(person_type, curr_posn, grid, all_neighbor_posns, pv)
    ## Find utilities at all empty locations
    locs_utils = utilities_at_emptylocs(person_type, 
                                        grid,
                                        all_neighbor_posns, 
                                        pv)
    ## Find the highest utility
    maxutil = values(locs_utils) |> maximum

    ## Find empty locations with the highest utility
    tol = sqrt(eps())
    locs_with_maxutil = filter(p -> maxutil - tol <= p[2] <= maxutil + tol,
                              locs_utils)
    
    ## Randomly choose one empty location from these highest utility locations
    loc, maxutil = rand(locs_with_maxutil)
    curr_util = utility(curr_posn, person_type, grid, 
                        all_neighbor_posns, pv)
    if curr_util >= maxutil
        curr_posn
    else
        loc
    end
end


function move_person!(curr_posn, grid, all_neighbor_posns, pv)
    pt = grid[curr_posn...]
    bestloc = find_best_loc(pt, curr_posn, grid, all_neighbor_posns, pv)
    # println("Curr posn: $(curr_posn)")
    # println("Best loc: $(bestloc)")
    ## change the curr_posn to empty
    grid[curr_posn...] = :E
    ## Change the best location from empty to person at the curr_posn
    grid[bestloc...] = pt
end



function replication!(rseed, numperiods, pv)
    Random.seed!(rseed)
    anp = all_neighboring_posns(pv[:nrows], pv[:ncols])
    gridinst = initgrid(pv[:nrows], pv[:ncols], pv[:propRed], pv[:propBlue])
    grid = deepcopy(gridinst)
    nrows, ncols = size(grid)
    for pd = 1:numperiods
        if pd % 100 == 0
            println("Start of period $(pd)")
        end
        for row in 1:nrows
            for col in 1:ncols
                pt = grid[row, col]
                if pt != :E
                    move_person!((row,col), grid, anp, pv)
                end
            end
        end
    end   
    return(gridinst, grid)
end


"""
Used in dm1 measure
"""
function expected_num_neighbors(posn,
                                neighbortype,
                                prop_red,
                                prop_blue,
                                anp)

end


function dm1(minority_type, grid, anp, prop_red, prop_blue)


end



function main(rseed, numperiods; nrows = 25, ncols = 25, threshold = 60.0)
    pv = params(;threshold=threshold)
    (initgrid, finalgrid) = replication!(rseed, numperiods, pv)
    draw_grid(initgrid, "initgrid_$(rseed).pdf")
    draw_grid(finalgrid, "finalgrid_$(rseed)_$(numperiods).pdf")
    
end

main(2, 1000, threshold = 75)
end ## end module
