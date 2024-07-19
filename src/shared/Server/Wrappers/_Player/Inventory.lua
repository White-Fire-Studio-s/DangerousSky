local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")

local wrapper = require(Packages.Wrapper)
local Zap = require(ReplicatedStorage.Zap)

local Inventory = {}

local inventories = setmetatable({}, { __mode = "k" })

function Inventory.wrap(holder: Player)

	local container = Instance.new("Folder", holder)

	--// Factory setup
	local self = wrapper(container)

	--// Private
	local items = {}

	--// Methods
	function self:addItem(item: Tool)

		if items[item] then return end
        
        if not item:IsA("Tool") then return end
        if not item:IsDescendantOf(holder) then return end

		items[item] = true;

		self:_host(item.Destroying:Once(function() self:removeItem(item) end))
	end
	function self:removeItem(item: Tool)

		if not items[item] or not item:IsA("Tool") then
			return
		end

		items[item] = nil;
	end
	
	function self:unequipEquippedItem()

		local equippedItem = holder.Character:FindFirstAncestorWhichIsA("Tool")
		if not equippedItem then return end
		if not items[equippedItem] then return end
		
		equippedItem.Parent = container
	end
	function self:hasItem(itemName)
		local item = holder.Backpack:FindFirstChild(itemName) or holder.Character:FindFirstChild(itemName)

		return item ~= nil and item:IsA("Tool")
	end
	function self:changeParents()
		
		for item in items do
			item.Parent = container
		end
	end 

	--// Listeners
	for _, item in container:GetChildren() do self:addItem(item) end

	self:_host(container.ChildAdded:Connect(function(item) self:addItem(item) end))
    self:_host(holder.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")
        
		for item in items do
			item.Parent = holder.Backpack
		end

        self:_host(humanoid.Died:Connect(self.changeParents))
    end))

	Zap.UnequipTools.setCallback(self.changeParents)

	inventories[holder] = self

	return self
end

function Inventory.get(rbxPlayer: Player)
	return inventories[rbxPlayer]
end

return Inventory