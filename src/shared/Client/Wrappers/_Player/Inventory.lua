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
local function Inventory(container: Folder)    
    local holder = Players.LocalPlayer
    local holderCharacter = holder.Character
    local holderHumanoid = holderCharacter:WaitForChild("Humanoid")

    local self = wrapper(container)
    local server = Replication.await(container)

    --// Private fields
    local slots = {}
    local items = setmetatable({}, { __mode = "k" })
    local leastKeyPressedTime = 0
    local equippedItem: Tool?

    --// Private methods
    local function setupInputs()
        local function bindAction(_,inputState: Enum.UserInputState, key: InputObject)
            if inputState ~= Enum.UserInputState.End then return end
            if os.clock() - leastKeyPressedTime < 0.1 then return end
        
            local itemSlot = slots[key.KeyCode.Value - 48]
            local item = itemSlot._item
            
            self:requestItemAction(item)
    
            leastKeyPressedTime = os.clock()
        end
        
        ContextActionSerivce:BindAction("KeyInputs",
            bindAction, false, unpack(KEYS)
        )
    end

    local function holderDied()
        if equippedItem then
            local equippedItemSlot = slots[self:getItemStot(equippedItem)]
            equippedItemSlot._interface.Size = UNEQUIPPED_SIZE

            equippedItem = nil
        end

        self:_host(holderHumanoid.Died:Connect(holderDied))
    end

    --// Methods
    function self:addItem(item: Tool)
        if items[item] or not item:IsA("Tool") then
            return
        end

        local slotsLength = #slots
        if slotsLength < 9 then
            self:addItemSlot(item, slotsLength + 1)
        end

        items[item] = { isEquipped = false }
    end

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

    function self:removeItem(item: Tool)
        if not items[item] or not item:IsA("Tool") then
            return
        end

        local itemSlot = self:getItemStot(item)
        if itemSlot then
            self:removeItemSlot(itemSlot)
        end
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
        local itemSlot = slots[self:getItemStot(item)]
        local itemSlotInterface = itemSlot._interface

        if equippedItem and equippedItem ~= item then
            local equippedItemSlot = slots[self:getItemStot(equippedItem)]

            equippedItemSlot._interface.Size = UNEQUIPPED_SIZE
        end

        if item:IsDescendantOf(holder) then
            server:invokeEquipItemAsync(item)

            itemSlotInterface.Size = EQUIPPED_SIZE
            equippedItem = item
            return
        end

        server:invokeUnequipItemAsync(item)
        itemSlotInterface.Size = UNEQUIPPED_SIZE
        equippedItem = nil
    end

    function self:getItemStot(item: Tool)
        for slot, itemData in slots do
            if itemData._item == item then
                return slot
            end
        end
    end

    --//
    setupInputs()

    --// Listeners
    for _, item in container:GetChildren() do self:addItem(item) end
    self:_host(container.ChildAdded:Connect(function(item) self:addItem(item) end))
    self:_host(holderHumanoid.Died:Connect(holderDied))

    return self
end

return Inventory