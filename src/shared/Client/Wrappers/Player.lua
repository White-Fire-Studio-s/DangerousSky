--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Wrappers = ReplicatedStorage:WaitForChild("Client")
    :WaitForChild("Wrappers")

--// Imports
local Inventory = require(Wrappers._Player.Inventory)
local wrapper = require(Packages.Wrapper)

--// Player
local Player = {}

function Player.wrap(rbxPlayer: Player)
    if rbxPlayer ~= game.Players.LocalPlayer then
        rbxPlayer:WaitForChild("Inventory"):Destroy()
        rbxPlayer:WaitForChild("Profile"):Destroy()

        return
    end

    local self = wrapper(rbxPlayer)
    self.Inventory = Inventory.wrap(rbxPlayer:WaitForChild("Inventory"))

    return self
end

return Player