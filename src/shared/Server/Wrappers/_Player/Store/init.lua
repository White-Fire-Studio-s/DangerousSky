--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Configuration = ReplicatedStorage:WaitForChild("Configuration")

--// Imports
local Prices = require(Configuration.StorePrices)
local Profile = require(ReplicatedStorage.Server.Wrappers._Player.Profile)
local Zap = require(ReplicatedStorage.Zap.Server)

--// Store
local Store = {}

local function purchase(rbxPlayer: Player, data: {type: string, itemName: string})
    
    local profile = Profile.get(rbxPlayer)

    local price = Prices[data.type][data.itemName]
    local traitPurchase = require(script[data.type])

    if profile.Statistics.Gems < price then
        return
    end

    local sucess = traitPurchase(rbxPlayer, data.itemName)
    if sucess then
        profile.Statistics.Gems -= price
        _G.ORDERED_STATISTIC[rbxPlayer].Gems.value = math.max(0, _G.ORDERED_STATISTIC.Gems.value - price)
    end

    return sucess
end

Zap.StorePurchase.setCallback(purchase)

return Store