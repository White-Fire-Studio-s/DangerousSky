local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MainGui = Players.LocalPlayer.PlayerGui:WaitForChild("Main")
local EffectsDisplay = MainGui:WaitForChild("EffectsDisplay")

local Round = ReplicatedStorage:WaitForChild("Round") :: Configuration

--// Init
return function ()
    
    for _, display in EffectsDisplay:GetChildren() do

        if not display:IsA("ImageLabel") then continue end

        display.Visible = Round:GetAttribute(display.Name)
    end

    Round.AttributeChanged:Connect(function(attribute: string)

        local display = EffectsDisplay:FindFirstChild(attribute)
        if not display then return end

        display.Visible = Round:GetAttribute(display.Name)
    end)
end