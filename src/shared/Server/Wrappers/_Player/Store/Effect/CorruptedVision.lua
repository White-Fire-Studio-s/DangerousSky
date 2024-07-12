--// Services
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables
local Round = require(ReplicatedStorage.Server.Wrappers.Round).get()
local CorruptedVision: ColorCorrectionEffect = Lighting:WaitForChild("CorruptedVision")

local function trait()
    local h, s = math.random(), math.random()

    CorruptedVision.Enabled = true
    CorruptedVision.TintColor = Color3.fromHSV(h, s, 0.8)

    Round.timerEnded:once(function()
        CorruptedVision.Enabled = false
    end)
end

return trait