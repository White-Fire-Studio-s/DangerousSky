local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local ServerPackages = ServerStorage:WaitForChild("Packages")

local Replicator = require(ServerPackages.Replicator)
local wrapper = require(Packages.Wrapper)

local function Inventory(container: Folder)
    local holder = container:FindFirstAncestorWhichIsA("Player") :: Player
    local holderCharacter = holder.CharacterAdded:Wait()
    local holderHumanoid = holderCharacter:WaitForChild("Humanoid")

    --// Factory setup
    local self = wrapper(container)
    local client = Replicator.get(container)

    --// Private
    local items = setmetatable({}, { __mode = "k" })
    local equippedItem: Tool

    local function holderDied()
        if equippedItem then
            equippedItem.Parent = container
            equippedItem = nil
        end

        holderCharacter = holder.CharacterAdded:Wait()
        holderHumanoid = holderCharacter:WaitForChild("Humanoid")

        self:_host(holderHumanoid.Died:Connect(holderDied))
    end

    --// Methods
    function self:addItem(item: Tool)
        if items[item] then return end
        if not item:IsA("Tool") then return end
        if not item:IsDescendantOf(holder) then return end

        items[item] = true;
        item.Destroying:Once(function() self:removeItem(item) end)
    end

    function self:removeItem(item: Tool)
        if not items[item] or not item:IsA("Tool") then
            return
        end

        items[item] = nil;
    end

    function self:equipItem(item: Tool)
        if not items[item] then
            return
        end

        if equippedItem and equippedItem ~= item then
            self:unequipItem(equippedItem)
        end

        item.Parent = holder.Character
        equippedItem = item
    end

    function self:unequipItem(item: Tool)
        if not items[item] then
            return
        end

        item.Parent = container
    end

    --// Client
    function client.EquipItem(_,item) self:equipItem(item) end 
    function client.UnequipItem(_,item) self:unequipItem(item) end    
   
    --// Listeners
    for _, item in container:GetChildren() do self:addItem(item) end

    self:_host(container.ChildAdded:Connect(function(item) self:addItem(item) end))
    self:_host(holderHumanoid.Died:Connect(holderDied))

    return self
end

return Inventory