--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Wrappers = ReplicatedStorage:WaitForChild("Server")
    :WaitForChild("Wrappers")

--// Imports
local Inventory = require(Wrappers._Player.Inventory)
local Profile = require(Wrappers._Player.Profile)
local wrapper = require(Packages.Wrapper)

--// Player
local Player = {}

function Player.wrap(rbxPlayer: Player)
    local inventoryContainer = Instance.new("Folder", rbxPlayer)
    inventoryContainer.Name = "Inventory"

    local profileContainer = Instance.new("Folder", rbxPlayer)
    profileContainer.Name = "Profile"

    local self = wrapper(rbxPlayer)
    self.Inventory = Inventory.wrap(inventoryContainer)
    self.Profile = Profile.wrap(profileContainer)

    return self
end

return Player