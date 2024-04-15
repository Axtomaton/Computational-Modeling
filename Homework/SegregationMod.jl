
module SegregationMod

import Random
import OrderedCollections as OC

import Luxor as L

mutable struct Params
    nrows::Int	
    ncols::Int
    propRed::Float64
    propBlue::Float64
    threshold::Float64
    a::Float64
    d::Float64
end


function params(;
                nrows = 25,
                ncols = 25,
                propRed = 0.4,
                propBlue = 0.4,
                threshold = 60.0,
                a = 20.0,
                d = 1.0)
    Params(nrows, ncols, propRed, propBlue, threshold, a, d)
end


"""
This is the initial grid.
People are distributed randomly across this grid.
"""
function initgrid(nrows, ncols, propred, propblue)
    numcells = nrows * ncols
    mat = Matrix{Symbol}(undef, nrows, ncols)
    mat .= :E
    
    posns = [(r,c) for r = 1:nrows for c = 1:ncols]
    rndposns = Random.shuffle(posns)
    numred = (propred * numcells) |> floor |> Int
    numblue = (propblue * numcells) |> floor |> Int
    
    redposns = @view rndposns[1:numred]
    blueposns = @view rndposns[numred+1:numred+numblue]
    elocs = @view rndposns[numred+numblue+1:end]

    for posn in redposns
        mat[posn...] = :R
    end
    
    for posn in blueposns
        mat[posn...] = :B
    end

    return (mat, elocs)
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
    threshold = pv.threshold
    a = pv.a
    d = pv.d
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
function utilities_at_emptylocs(elocs, grid, all_neighbor_posns, pv)
    output_red = OC.OrderedDict{Tuple{Int64, Int64}, Float64}()
    output_blue = OC.OrderedDict{Tuple{Int64, Int64}, Float64}()
    for loc in elocs
        output_red[loc] = utility(loc, :R, grid, all_neighbor_posns, pv)
        output_blue[loc] = utility(loc, :B, grid, all_neighbor_posns, pv)
    end
    (output_red, output_blue)
end


function find_best_loc(person_type, curr_posn,
                      utils_red_elocs,
                      utils_blue_elocs, 
                      grid, all_neighbor_posns, pv)
    ## Find utilities at all empty locations
    locs_utils = (person_type == :R) ? utils_red_elocs : utils_blue_elocs

    ## Find the highest utility
    maxutil = values(locs_utils) |> maximum
    curr_util = utility(curr_posn, person_type, grid, 
                        all_neighbor_posns, pv)

    if curr_util >= maxutil 
        return curr_posn
    else
        ## Find empty locations with the highest utility
        tol = sqrt(eps())
        locs_with_maxutil = filter(p -> maxutil - tol <= p[2] <= maxutil + tol,
                                  locs_utils)
        
        ## Randomly choose one empty location from these highest utility locations
        res = rand(locs_with_maxutil)
        return res[1]
    end
end


function update_eloc_utils!(posn,
                            add_or_remove,
                            utils_red_elocs, 
                            utils_blue_elocs,
                            grid,
                            anp,
                            pv)
    
    if add_or_remove == :add
        util_red = utility(posn, :R, grid, anp, pv)	
        utils_red_elocs[posn] = util_red
        util_blue = utility(posn, :B, grid, anp, pv)
        utils_blue_elocs[posn] = util_blue
    elseif add_or_remove == :remove
        delete!(utils_red_elocs, posn)
        delete!(utils_blue_elocs, posn)
    end
    nbrposns = anp[posn]
    for nbrposn in nbrposns
        if grid[nbrposn...] == :E
            util_red_nbr = utility(nbrposn, :R, grid, anp, pv)	
            util_blue_nbr = utility(nbrposn, :B, grid, anp, pv)	
            utils_red_elocs[nbrposn] = util_red_nbr
            utils_blue_elocs[nbrposn] = util_blue_nbr
        end
    end
end


function move_person!(curr_posn, 
                      utils_red_elocs,
                      utils_blue_elocs,
                      grid, all_neighbor_posns, pv)
    pt = grid[curr_posn...]
    bestloc = find_best_loc(pt, curr_posn, 
                           utils_red_elocs,
                           utils_blue_elocs,
                           grid, all_neighbor_posns, pv)
    if bestloc != curr_posn
        ## change the curr_posn to empty
        grid[curr_posn...] = :E
        ## Change the best location from empty to person at the curr_posn
        grid[bestloc...] = pt
        update_eloc_utils!(curr_posn, :add, 
                           utils_red_elocs, utils_blue_elocs,
                           grid, all_neighbor_posns, pv)
        
        update_eloc_utils!(bestloc, :remove, 
                           utils_red_elocs, utils_blue_elocs,
                           grid, all_neighbor_posns, pv)
    end
end



function replication!(rseed, numperiods, pv)
    Random.seed!(rseed)
    anp = all_neighboring_posns(pv.nrows, pv.ncols)
    gridinst, elocs = initgrid(pv.nrows, pv.ncols, pv.propRed, pv.propBlue)
    grid = deepcopy(gridinst)
    nrows, ncols = size(grid)
    utils_red_elocs, utils_blue_elocs = utilities_at_emptylocs(elocs,
                                                                grid, 
                                                                anp,
                                                                pv)
    start_time = time()
    for pd = 1:numperiods
        if pd % 1000 == 0
            println("Start of period $(pd)")
        end
        for row in 1:nrows
            for col in 1:ncols
                pt = grid[row, col]
                if pt != :E
                    move_person!(
                        (row,col), 
                        utils_red_elocs, 
                        utils_blue_elocs, 
                        grid, anp, pv
                    )
                end
            end
        end
    end   
    stop_time = time()
    println("Time taken: $(stop_time - start_time)")

    return(gridinst, grid)
end



"""
Used in dm1 measure
"""
function expected_num_neighbors(posn, neighbortype, prop_red, prop_blue, anp)
    neighbor_posns = anp[posn]
    num_neighbors = length(neighbor_posns)

    if neighbortype == :R
        expected_num = num_neighbors * prop_blue
    else
        expected_num = num_neighbors * prop_red
    end

    return expected_num
end

function dm1(minority_type, grid, anp, prop_red, prop_blue)
    m, n = size(grid)
    num_agents = m * n

    diversity_measure = 0.0
    expected_num_neighbors_dict = Dict{Tuple{Int64, Int64}, Int64}()

    for i in 1:m
        for j in 1:n
            if grid[i, j] == minority_type
                num_other_type = count(x -> x != minority_type && x != :E, anp[(i, j)][1])
                expected_num_neighbors_dict[(i, j)] = round(Int, expected_num_neighbors((i, j), :B, prop_red, prop_blue, anp))
            else
                num_other_type = count(x -> x == minority_type && x != :E, anp[(i, j)][1])
                expected_num_neighbors_dict[(i, j)] = round(Int, expected_num_neighbors((i, j), :R, prop_red, prop_blue, anp))
            end
            expected_num_other_type = expected_num_neighbors_dict[(i, j)]
            diversity_measure += min(num_other_type / expected_num_other_type, 1)
        end
    end
    diversity_measure /= num_agents

    return diversity_measure
end

"""
For the DM2 measure, use only those occupied locations which are not islands. That is, they have at least one neighboring position that is occupied
"""

function dm2(grid, anp, prop_red, prop_blue)
    num_occupied = count(x -> x != :E, grid)  # Count the number of occupied locations
    diversity_measure = 0.0

    for loc in keys(anp)
        i, j = Tuple(loc)  # Extract row and column indices from the CartesianIndex
        loc_type = grid[i, j]  # Use array indexing to access the grid element
        nbrs = anp[loc]  # Get neighboring positions

        num_neighbors_other_type = sum(grid[p...] != loc_type && grid[p...] != :E for p in nbrs)  # Count neighbors of a different type
        num_neighbors_occupied = sum(grid[p...] != :E for p in nbrs)  # Count occupied neighbors

        if num_neighbors_occupied != 0
            expected_num_other_type = 0.0  # Initialize expected_num_other_type

            if loc_type == :R
                expected_num_other_type = num_neighbors_occupied * prop_blue  # Expected number of blue neighbors
            elseif loc_type == :B
                expected_num_other_type = num_neighbors_occupied * prop_red  # Expected number of red neighbors
            end

            if expected_num_other_type != 0
                p_loc_type = min(num_neighbors_other_type / expected_num_other_type, 1.0)  # Ensure probability is bounded between 0 and 1
                diversity_measure += p_loc_type  # Accumulate the probability for each location
            end
        end
    end

    return diversity_measure / num_occupied  # Compute final diversity measure by dividing by the number of occupied locations
end



function main(; nrows = 50, ncols = 50, numperiods = 10000)
    prop_red = 0.4
    prop_blue = 0.4
    threshold = 50.0

    final_dm2_values = Float64[]  # Create an empty array to store final DM2 values

    for rseed in 1:100
        println("Replication: ", rseed)

        # Initialize the grid with random distributions of :R and :B types
        gridinst, grid = replication!(rseed, numperiods, params(
            nrows = nrows,
            ncols = ncols,
            propRed = prop_red,
            propBlue = prop_blue,
            threshold = threshold,
            a = 20.0,
            d = 1.0
        ))

        anp = all_neighboring_posns(nrows, ncols)
        final_dm2 = dm2(gridinst, anp, prop_red, prop_blue)
        push!(final_dm2_values, final_dm2)
        println("Final DM2 value after 10,000 periods: ", final_dm2)
    end

    avg_final_dm2 = sum(final_dm2_values) / length(final_dm2_values)
    println("SIze of final_dm2_values: ", length(final_dm2_values))
    println("Average final DM2 value over 100 replications after 10,000 periods: ", avg_final_dm2)
end

main()





end ## end module
