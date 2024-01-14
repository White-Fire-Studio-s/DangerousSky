--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionSerivce = game:GetService("ContextActionService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Assets = ReplicatedStorage:WaitForChild("Assets")

--// Imports
local Replication = require(Packages.Replication)
local wrapper = require(Packages.Wrapper)

--// Assets
local ItemSlot = Assets:WaitForChild("ItemSlot")

--// Constants
local KEYS = {
    [1] = Enum.KeyCode.One;
    [2] = Enum.KeyCode.Two;
    [3] = Enum.KeyCode.Three;
    [4] = Enum.KeyCode.Four;
    [5] = Enum.KeyCode.Five;
    [6] = Enum.KeyCode.Six;
    [7] = Enum.KeyCode.Seven;
    [8] = Enum.KeyCode.Eight;
    [9] = Enum.KeyCode.Nine;
}

local UNEQUIPPED_SIZE = ItemSlot.Size
local EQUIPPED_SIZE = UDim2.fromScale(UNEQUIPPED_SIZE.X.Scale * 1.05, UNEQUIPPED_SIZE.Y.Scale * 1.05)

local InventoryScreenGui = Players.LocalPlayer.PlayerGui:WaitForChild("Inventory")
local InventoryBar = InventoryScreenGui:WaitForChild("Bar")

--// Wrapper
local function Inventory(backpack: Backpack)
    local server = Replication.await(backpack)
    local self = wrapper(backpack)

    --// Private
    local slots = {}
    local items = setmetatable({}, { __mode = "k" })
    local leastKeyPressedTime = 0

    --// Private methods
    local function setupInputs()
        local function bindAction(_,inputState: Enum.UserInputState, key: InputObject)
            if inputState ~= Enum.UserInputState.End then
                return
            end
    
            if os.clock() - leastKeyPressedTime < 0.1 then
                return
            end
        
            local itemSlot = self.Slots[table.find(KEYS, key.KeyCode)]
            local item = itemSlot._item
            
            self:RequestItemAction(item)
    
            leastKeyPressedTime = os.clock()
        end
        
        ContextActionSerivce:BindAction("KeyInputs", bindAction, false, unpack(KEYS))
    end

    --// Methods
    function self:addItemSlot(item: Tool, slot: number)
        table.insert(slots, {
            _item = item,
            _interface = self:createItemInterface(item, slot)
        })
    end

    function self:createItemInterface(item: Tool, slot: number)
        local slotInterface = ItemSlot:Clone()

        slotInterface.LayoutOrder = slot
        slotInterface.Parent = InventoryBar
        slotInterface.Slot.Text = slot
        slotInterface.ItemImage.Image = item.TextureId or ""
    
        slotInterface.ItemName.Visible = item.TextureId == ""
        slotInterface.ItemName.Text = item.Name
    
        slotInterface.MouseButton1Click:Connect(function()
            self:requestItemAction(item)
        end)

        return slotInterface
    end

    function self:removeItemSlot(slot: number)
        local slotData = slots[slot]

        slotData._interface:Destroy()
        table.remove(slots, slot)

        self:fixSlotsOrder()
    end

    function self:fixSlotsOrder()
        for order, slotData in self.Slots do
            local slotInterface = slotData._slotInterface
    
            slotInterface.Slot.Text = order
            slotInterface.LayoutOrder = order
        end
    end

    function self:requestItemAction(item: Tool)
        if items[item].isEquipped then
            server:invokeUnequipItemAsync(item)
                :andThen(function() items[item].isEquipped = false end)
                :catch(warn)

            return
        end

        server:invokeEquipItemAsync(item)
            :andThen(function() items[item].isEquipped = true end)
            :catch(warn)
    end

    function self:getItemStot(item: Tool)
        for slot, itemData in slots do
            if itemData._item == item then
                return slot
            end
        end
    end

    --// Connections
    self.itemAdded:connect(function(item: Tool)
        local slotsLength = #slots
        if slotsLength < 9 then
            self:addItemSlot(slotsLength, slotsLength + 1)
        end

        items[item] = { isEquipped = false }
    end)

    self.itemRemoved:connect(function(item: Tool)
        local itemSlot = self:getItemStot(item)
        if itemSlot then
            self:removeItemSlot(itemSlot)
        end
    end)

    setupInputs()

    return self
end

return Inventory