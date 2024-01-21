local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundContainer = ReplicatedStorage:WaitForChild("Round")

local PlayerGui = Players.LocalPlayer.PlayerGui
local MainScreen = PlayerGui:WaitForChild("Main")
local Top = MainScreen:WaitForChild("Top")
local Clock = Top:WaitForChild("Clock")
local Multiplicator = Clock:WaitForChild("Multiplicator")

local function setTimer()
    local timer = RoundContainer:GetAttribute("timer")
    
    local minutes = math.floor(timer / 60)
    local seconds = timer % 60

    Clock.TextLabel.Text = string.format("%d:%.2d", minutes, seconds)
end

local function setMultiplicator()
    local timeDecrease = RoundContainer:GetAttribute("timeDecrease")
    
    Multiplicator.Text = `{timeDecrease}x`
    Multiplicator.Visible = timeDecrease ~= 1
end

return function() --// Init
    setTimer()
    setMultiplicator()
    RoundContainer:GetAttributeChangedSignal("timer"):Connect(setTimer)
    RoundContainer:GetAttributeChangedSignal("timeDecrease"):Connect(setMultiplicator)
end