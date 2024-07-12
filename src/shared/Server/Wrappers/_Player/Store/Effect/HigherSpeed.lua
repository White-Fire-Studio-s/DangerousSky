--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables
local Round = require(ReplicatedStorage.Server.Wrappers.Round).get()


local function trait(rbxPlayer: Player)

    local rbxHumanoid = rbxPlayer.Character:WaitForChild("Humanoid")

    rbxHumanoid.WalkSpeed = 30
    workspace:SetAttribute("roundSpeed", 30)

    Round.timerEnded:once(function()
        rbxHumanoid.WalkSpeed = 16
        workspace:SetAttribute("roundSpeed", 16)
    end)
end

return trait