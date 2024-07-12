--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables
local Round = require(ReplicatedStorage.Server.Wrappers.Round).get()

local function trait()
    local defaultStagesAmount = Round.stagesAmount
    local timer = Round.timer

    Round.stagesAmount += 5
    Round.timer = timer

    Round.timerEnded:once(function()
        Round.stagesAmount = defaultStagesAmount
    end)
end

return trait