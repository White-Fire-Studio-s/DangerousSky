--[[local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local rbxPlayer = Players.LocalPlayer

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

warn('hello everyone')

local inventory = require(ReplicatedStorage.Client.Factories.Inventory)
local backpack = rbxPlayer:WaitForChild("Inventory")

inventory(backpack)]]