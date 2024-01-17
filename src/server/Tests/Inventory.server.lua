--[[local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Inventory = require(ReplicatedStorage.Server.Factories.Inventory)
local plr = game.Players:GetPlayers()[1] or game.Players.PlayerAdded:Wait()

local container = Instance.new("Folder", plr)
container.Name = "Inventory"

local inventory = Inventory(container)]]