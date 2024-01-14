local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Replicator = require(Packages.Replicator)
local wrapper = require(Packages.Wrapper)

local function Inventory(backpack: Backpack)
    local rbxPlayer = backpack.Parent :: Player

    --// Factory setup
    local self = wrapper(backpack)
    local client = Replicator.get(rbxPlayer)

    --// Signals
    local itemAdded = client:_signal("itemAdded")
    local itemRemoved = client:_signal("itemRemoved")

    --// Private
    local items = setmetatable({}, { __mode = "k" })
    local currentEquippedItem: Tool

    function self:addItem(item: Tool, data)
        if items[item] or not item:IsA("Tool") then
            return
        end

        itemAdded:_emitOn({rbxPlayer}, item)
        items[item] = true;
        item.Destroying:Connect(function() self:removeItem(item) end)
    end

    function self:removeItem(item: Tool)
        if not items[item] or not item:IsA("Tool") then
            return
        end

        itemRemoved:_emitOn({rbxPlayer}, item)
        items[item] = nil;
    end

    --// Client
    function client:equipItem(item: Tool)
        if currentEquippedItem then
            client:unequipItem(item)
        end

        item.Parent = rbxPlayer.Character
        currentEquippedItem = item
    end

    function client:unequipItem(item: Tool)
        item.Parent = backpack
    end

    backpack.ChildAdded:Connect(function(item) self:addItem(item) end)

    return self
end

return Inventory