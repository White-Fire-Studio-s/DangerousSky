--// Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
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
local SpecialObject = require(script.Parent.SpecialObject)

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
    task.wait(2)
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

    function self:handleStageInformation()


        local stageZone = Zone.fromRegion(self.center, self.size * REGION_MULTIPLIER)
        local function showStageInformation()
            shown:Play()
    
            StageInfo.StageName.Text = self.name
            StageInfo.StageName.TextColor3 = self.baseColor
            StageInfo.StageOwners.Text = `by {self.owners or "unknown"}`
        end
    
        local entered = stageZone.localPlayerEntered:Connect(showStageInformation)
    
        self:cleaner(function()
            stageZone:destroy()
            entered:Disconnect()
        end)
    end
    function self:loadSpecialObject(object: BasePart | Model)

        if not object:HasTag("specialObject") then
            return
        end

        local kinds = object:GetTags()
        
        SpecialObject.wrap(object, kinds)
    end
    function self:unloadSpecialObject(rbxObject: BasePart | Model)
        local shallow = SpecialObject.findShallow(rbxObject)

        if not shallow then return end

        for _, texture in rbxObject:GetChildren() do
            if not texture:IsA("Texture") then
                continue
            end

            texture.Transparency = 0
        end

        shallow:Destroy()
    end

    self:handleStageInformation()

    --// Special Objects Loader
    self:_host(task.defer(function()

        local specialObjects = stageModel:WaitForChild("SpecialObjects", math.huge)

        for _, specialObject in specialObjects:GetDescendants() do
            self:loadSpecialObject(specialObject)
        end
    
        specialObjects.DescendantAdded:Connect(function(...) self:loadSpecialObject(...) end)
        specialObjects.DescendantRemoving:Connect(function(...) self:unloadSpecialObject(...) end)
        
        self:cleaner(function()
            for _, specialObject in specialObjects:GetDescendants() do
                self:unloadSpecialObject(specialObject)
            end
        end)
    end))

    return self
end

return Stage