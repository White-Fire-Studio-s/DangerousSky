local ReplicatedStorage = game:GetService("ReplicatedStorage")
--// Imports
local StoreDisplay = require(script.Parent.StoreDisplay)
local Button = require(script.Parent.Parent.Components.Button)
local Prices = require(ReplicatedStorage.Configuration.StorePrices)

--// Wrapper
local function wrap(rbxButton: TextButton)

    local itemDisplay = Button.get(rbxButton)

    itemDisplay.Clicked:connect(function()
        StoreDisplay:set(itemDisplay)
    end)

    local sucess, price = pcall(function()
        return Prices[itemDisplay.Type][itemDisplay.DisplayName]
    end)

    price = if sucess then price else itemDisplay.DisplayPrice

    itemDisplay.DisplayPrice = price

    return itemDisplay
end

return wrap