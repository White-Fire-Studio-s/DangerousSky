--// Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// Assets
local PlayerGui = Players.LocalPlayer.PlayerGui
local MainScreen = PlayerGui:WaitForChild("Main")
local StageInfo = MainScreen:WaitForChild("StageInfo")

local StageName = StageInfo:WaitForChild("StageName")
local StageOwners = StageInfo:WaitForChild("StageOwners")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")

--// Imports
local Wrapper = require(Packages.Wrapper)
local Zone = require(Packages.Zone)

--// Constants
local TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
local FADED = { GroupTransparency = 1 }
local SHOWN = { GroupTransparency = 0 }

local REGION_MULTIPLIER = Vector3.new(3, 10, 1)

--// Tweens
local shown = TweenService:Create(StageInfo, TWEEN_INFO, SHOWN)
local faded = TweenService:Create(StageInfo, TWEEN_INFO, FADED)

--// Listeners
shown.Completed:Connect(function()
    task.wait(1.5)
    if 
        shown.PlaybackState == Enum.PlaybackState.Begin or
        shown.PlaybackState == Enum.PlaybackState.Playing 
    then
        return
    end

    faded:Play()
end)

--// Module
local Stage = {}

function Stage.wrap(stageModel: Model)
    
    local self = Wrapper(stageModel)
    local stageCFrame, stageSize = stageModel:GetBoundingBox()
    if stageSize == Vector3.zero then
        task.wait()

        stageCFrame, stageSize = stageModel:GetBoundingBox()
    end

    stageSize *= REGION_MULTIPLIER

    local stageZone = Zone.fromRegion(stageCFrame, stageSize)
    
    local function showStageInformation()
        
        shown:Play()

        StageName.Text = self.name
        StageName.TextColor3 = self.baseColor
        StageOwners.Text = `by {self.owners or "unknown"}`
    end

    local entered = stageZone.localPlayerEntered:Connect(showStageInformation)

    self:cleaner(function() 
        
        entered:Disconnect()
        stageZone:destroy()
    end)

    return self
end

return Stage