local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(script.Parent.Components.Button)
local Enum = require(script.Parent.Components.Enum)
local Zap = require(ReplicatedStorage.Zap)

--// Assets
local PlayerGui = Players.LocalPlayer.PlayerGui
local MainScreen = PlayerGui:WaitForChild("Main")
local CodeCreator = MainScreen:WaitForChild("CodeCreator")

local TIMESTAMPS_INCREASE = {
    [1] = 1000000000;
    [2] = 86_400;
    [3] = 604_800;
    [4] = 2_592_000;
    [5] = 31_540_000
}

return function ()
    
    local Button = Button.get(CodeCreator.Main.Button.TextButton)
    local Duration = Enum.get(CodeCreator.Main.Duration)

    Button.Clicked:connect(function()

        local code = CodeCreator.Main.Code.Text
        if code == "" then return warn(1) end

        local increase = TIMESTAMPS_INCREASE[Duration.currentPosition]

        local gems = CodeCreator.Main.Gems.Text
        if not tonumber(gems) then return warn(2) end

        Zap.CreateCode.fire({
            rewards = { gems = tonumber(gems) };
            expiresAt = DateTime.now().UnixTimestamp + increase;
            code = code
        })
    end)
end