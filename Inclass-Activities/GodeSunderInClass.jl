module GodeSunderInClass

import DataFrames as DF
import Distributions as Dist
import StatsBase as SB

const unif0200 = Dist.Uniform()
##-------------------------------------------------------------------------
## Custom Types
##-------------------------------------------------------------------------
## Create a Buyer type
## A buyer is characterized by three fields: id, value/wtp, and bid

mutable struct Buyer 
    id::Int
    wtp::Float64
    bid::Float64
end


## Create a Seller type
## A seller is characterized by three fields: id, cost, ask

mutable struct Seller
    id::Int
    cost::Float64
    ask::Float64
end


##-------------------------------------------------------------------------
"""
Create a dictionary of parameters
"""
function params()
    Dict(
        :Nb => 100,
        :Ns => 100, 
        :MinVal => 0.0,
        :MaxVal => 200,
        :MinCost => 0,
        :MaxCost => 200
    )
end


##-------------------------------------------------------------------------
"""
Create an empty dataframe for storing trades.
Each trade has four features: rseed, buyer valuation, seller cost and price.
"""
function init_trades()
    DF.DataFrame(
        rseed= Int[],
        wtp= Float64[],
        cost= Float64[],
        price= Float64[]
    )
end

##-------------------------------------------------------------------------
"""
We will compare the trades that occur in the Gode-Sunder model with those
the perfectly competitive outcome.

This is the dataframe for storing the perfectly competitive outcome.
Required information: rseed, eqmprice, eqmqty, eqmsurplus.
"""
function init_eqmresults()
    DF.DataFrame(
        rseed = int[],
        eqmprice= Float64[],
        eqmqty = int[],
        eqmsurplus = Float64[]
    )
end


##-------------------------------------------------------------------------
"""
Generate and return the population (array) of buyers.
"""
function gen_buyers(numbuyers, minval, maxval)
    unifdist = Dist.Uniform(minval, maxval)
    buyer_vals = rand(unifdist, numbuyers)
    [Buyer(i, buyer_vals[i], -Inf) for i=1:numbuyers] 
end


##-------------------------------------------------------------------------
"""
Generate a population of sellers.
"""
function gen_sellers(numsellers, mincost, maxcost)
    unifdist = Dist.Uniform(mincost, maxcost)
    [Seller(i, rand(unifdist), Inf) for i=1:numsellers]
end

##-------------------------------------------------------------------------
"""
Calculate the perfectly competitive equilibrium. We need to 
take account of discreteness in our data.
Return the eqmprice, eqmqty and
social surplus (= consumer surplus + producer surplus)
(referred to as eqmsurplus)
"""
function calc_eqm(buyers::Array{Buyer, 1}, sellers::Array{Seller, 1})
    ##sort buyers in a descending order based on willingness to pay.
    buyers_sorted = sort(buyers, by = x -> x.wtp, rev=true) #rev by default it's ascending 
    ## sort sellers  in an ascending order based on cost of production.
    sellers_sorted = sort(sellers, by = x -> x.cost)
    ## Calculate equilibrium quantity and surplus. 
        ## This is the highest quality q such that wtp(buyer in post q) >= cost(seller in pos q)
    eqm_qty = 0
    surplus = 0.0

    for (buyer, seller) in zip(buyers_sorted, sellers_sorted)
        diff = buyer.wtp - seller.cost
        if diff >= 0
            eqm_qty += 1
            surplus += diff
        else
            break
        end

        eqm_price = (buyers_sorted[eqm_qty].wtp + sellers_sorted[eqm_qty].cost) / 2.0

        #return these three as a dictionary
        return Dict(
            :eqm_qty => eqm_qty, 
            :eqm_price => eqm_price, 
            :eqm_surplus => surplus
        )

    end
    
    ## Calculate equilibrium price
        ## (willingness to pay - cost)/2 for buyer and seller in position q.

    ##r return these things as a dictionary. 
end


##-------------------------------------------------------------------------
"""
Buyers randomly decide how much to offer (their bid) 
subject to the constraint that they don't pay more than their valuation.
Given buyers array, update the array with their bid.
"""
function gen_bids!(buyers :: Array{Buyer, 1})
    for buyer in buyers
        unifdist = Dist.Uniform(0.0, buyer.wtp)
        buyer.bid = rand(unifdist)
    end
end


##-------------------------------------------------------------------------
"""
Sellers randomly decide how much to ask  
subject to the constraint that they don't ask for less than their cost.
Given the sellers array, update the array with their asks.
"""
function gen_asks!(sellers :: Array{Seller, 1}, maxval)
    for seller in sellers
        if seller.cost < maxval
            unifdist = Dist.Uniform(seller.cost, maxval)
            seller.ask = rand(unifdist)
        end
    end
end

##-------------------------------------------------------------------------
"""
Every buyer purchases at most one unit. 
When a buyer engages in a trade, we remove that buyer from the list of 
potential buyers.
"""
function remove_buyer(buyers :: Array{Buyer, 1}, buyer_to_rem :: Buyer)
    filter!(b -> b.id != buyer_to_rem.id, buyers)

end

##-------------------------------------------------------------------------
"""
Every seller sells at most one unit. 
When a seller engages in a trade, we remove that seller from the list of 
potential sellers.
"""
function remove_seller(sellers :: Array{Seller, 1}, seller_to_rem :: Seller)
    filter!(s -> s.id != seller_to_rem.id, sellers)

end


##-------------------------------------------------------------------------
"""
Implement the double-auction market that runs for 2 seconds
For each trade, record the buyer value, seller cost and the price.
Return the dataframe consisting of these three columns.
""" 
function calc_trades(buyers :: Array{Buyer, 1},
                     sellers :: Array{Seller, 1},
                     maxval)
    trade = DF.DataFrame(
        wtp= Float64[],
        cost= Float64[],
        price= Float64[]
    )
    buyers = 

    start_time = time()
    while time() <= start_time + 2
        gen_bids!(buyers)
        gen_asks!(sellers, maxval)
        sorted_buyers = sort(buyers, by = b -> b.bid, rev=true)
        sorted_sellers = sort(sellers, by = s -> s.ask)
        max_poss_qty = 0
        for (buyer, seller) in zip(sorted_buyers, sorted_sellers)
            if buyer.bid >= seller.ask
                max_poss_qty += 1
            else
                break
            end
        end
        trading_buyer = SB.sample(sorted_buyers[1:max_poss_qty])
        trading_seller = SB.sample(sorted_sellers[1:max_poss_qty])
        push!(trades, 
            [trading_buyer.wtp, 
            trading_seller.cost, 
            trading_buyer.bid])
        remove_buyer(buyers, trading_buyer)
        remove_seller(sellers, trading_seller)
        ## we need to remove seller and buyer from the population. 
    end

end


"""
Implement trades with a different rule than that
we first implemented.
For 1 second do the following:
    1. Draw random bids and asks.
    2. Find highest bid and pair that highest bid
    with the lowest ask.
    If this bid exceeds the ask, then
    this is a feasible trade. Add it to the list of trades.
    Remove the buyer and seller from the population of buyers and sellers.
    Go to step 1.
    Else if the bid is below the ask, go to Step 1.
"""
function calc_trades2(buyers :: Array{Buyer, 1},
                     sellers :: Array{Seller, 1},
                     maxval)


end



"""
Calculate the total surplus, quantity and average price given 
`mktdf`: the market outcome as a dataframe with buyer value, seller cost 
and trade price as columns.
Returns a dictionary with three values (surplus, quantity and avgprice)
"""
function marketagg(mkt_trades)
    ss = sum(mkt_trades.wtp - mkt_trades.cost)
    quantity = size(mkt_trades)[1]
    avgprice = Sb.mean(mkt_trades.price)

    return Dict(
                :surplus => ss,
                :quantity => quantity,
                :avgprice => avgprice
                )

end


"""
Run multiple replications of the simulation
"""
function run_reps(numreps :: Int64,
                  params)
    eqmdf = DataFrame(
        rseed = Int[],
        eqm_quantity = Int[],
        eqm_price = Float[],
        eqm_surplus = Float[]
    )

    zires = Df.DataFrame(
        rseed = Int[],
        zi_quantity = Int[],
        zi_avgprice = Float[],
        zi_surplus = Float[]
    )

    for rep=1:numreps
        Random.seed!(rep)
        
        buyers = gen_buyers(params[:Nb], 
                            params[:MinVal], 
                            params[:MaxVal])

        sellers = gen_sellers(params[:Ns],
                            params[:MinCost], 
                            params[:MaxCost])

        buyerscopy = deepcopy(buyers)
        sellerscopy = deepcopy(sellers)

        tradesdf = calc_trades(buyerscopy, sellerscopy, params[:MaxVal])
        mktagg = marketagg(tradesdf)

        mktagg[:rseed] = rep
        push!(zires, mktagg)

        #calcualte the equilibrium
        eqmres = calc_eqm(buyers, sellers)
        
        #add the equilibrium to the eqm
        eqmres[:rseed] = rep
        push!(eqmdf, eqmres)


    end
    return (eqmdf, zires)
end


## We want to compare the efficiency of the GS market with the 
## perfectly competitive market.
## Efficiency can be defined as the ratio:
## Surplus in the GS Mkt / Surplus in the perfectly competitive eqm.
function efficiency(eqmdf, gsmktdf)

end
end
