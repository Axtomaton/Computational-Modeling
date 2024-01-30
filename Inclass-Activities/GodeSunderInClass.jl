module GodeSunderInClass


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
end


##-------------------------------------------------------------------------
"""
Create an empty dataframe for storing trades.
Each trade has four features: rseed, buyer valuation, seller cost and price.
"""
function init_trades()
end

##-------------------------------------------------------------------------
"""
We will compare the trades that occur in the Gode-Sunder model with those
the perfectly competitive outcome.

This is the dataframe for storing the perfectly competitive outcome.
Required information: rseed, eqmprice, eqmqty, eqmsurplus.
"""
function init_eqmresults()
end


##-------------------------------------------------------------------------
"""
Generate and return the population (array) of buyers.
"""
function gen_buyers(numbuyers, minval, maxval)
end


##-------------------------------------------------------------------------
"""
Generate a population of sellers.
"""


##-------------------------------------------------------------------------
"""
Calculate the perfectly competitive equilibrium. We need to 
take account of discreteness in our data.
Return the eqmprice, eqmqty and
social surplus (= consumer surplus + producer surplus)
(referred to as eqmsurplus)
"""
function calc_eqm(buyers::Array{Buyer, 1}, sellers::Array{Seller, 1})
end


##-------------------------------------------------------------------------
"""
Buyers randomly decide how much to offer (their bid) 
subject to the constraint that they don't pay more than their valuation.
Given buyers array, update the array with their bid.
"""
function gen_bids!(buyers :: Array{Buyer, 1})
end


##-------------------------------------------------------------------------
"""
Sellers randomly decide how much to ask  
subject to the constraint that they don't ask for less than their cost.
Given the sellers array, update the array with their asks.
"""
function gen_asks!(sellers :: Array{Seller, 1}, maxval)
end

##-------------------------------------------------------------------------
"""
Every buyer purchases at most one unit. 
When a buyer engages in a trade, we remove that buyer from the list of 
potential buyers.
"""
function remove_buyer(buyers :: Array{Buyer, 1}, buyer_to_rem :: Buyer)
end

##-------------------------------------------------------------------------
"""
Every seller sells at most one unit. 
When a seller engages in a trade, we remove that seller from the list of 
potential sellers.
"""
function remove_seller(sellers :: Array{Seller, 1}, seller_to_rem :: Seller)
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
end


"""
Run multiple replications of the simulation
"""
function run_reps(numreps :: Int64,
                  params)
end


## We want to compare the efficiency of the GS market with the 
## perfectly competitive market.
## Efficiency can be defined as the ratio:
## Surplus in the GS Mkt / Surplus in the perfectly competitive eqm.
function efficiency(eqmdf, gsmktdf)
end









end
