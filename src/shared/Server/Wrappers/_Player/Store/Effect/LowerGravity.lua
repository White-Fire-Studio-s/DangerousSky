--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables
local Round = require(ReplicatedStorage.Server.Wrappers.Round).get()

local defaultGravity = workspace.Gravity

local function trait()

    workspace.Gravity = 70
    workspace:SetAttribute("roundGravity", 196.4 - 70)

    Round.timerEnded:once(function()
        task.defer(function()
            workspace.Gravity = defaultGravity
            workspace:SetAttribute("roundGravity", defaultGravity)
        end)
    end)
end

return trait