local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Zone = require(ReplicatedStorage.Packages.Zone)
local Wrapper = require(ReplicatedStorage.Packages.Wrapper)

local Splash = ReplicatedStorage.Assets.Effects.Splash

local function wrap(water: Model)

    local self = Wrapper(water)

    local cframe, size = water:GetBoundingBox()
    while size == Vector3.zero do
        task.wait()

        cframe, size = water:GetBoundingBox()
    end
    
    cframe *= CFrame.new(0, 0.1, 0)
    local zone = Zone.fromRegion(cframe, size)

    self:_host(zone.localPlayerEntered:Connect(function()
        local character = Players.LocalPlayer.Character
        local pivot = character:GetPivot()

        local foam = water:WaitForChild("Foam") :: BasePart

        local attachment = Instance.new("Attachment")
        attachment.CFrame = foam.CFrame:ToObjectSpace(CFrame.new(pivot.X, 4.576, pivot.Z))
        attachment.Parent = water:WaitForChild("Foam")

        for _, splashEffect in Splash:GetChildren() do
            local effect = splashEffect:Clone()
            effect.Parent = attachment

            effect:Emit(effect:GetAttribute("EmitCount"))
        end

        workspace.Soundtrack.SFX.Splash:Play()

        Debris:AddItem(attachment, 2)
    end))
end

for _, water in CollectionService:GetTagged("Water") do
    wrap(water)
end
CollectionService:GetInstanceAddedSignal("Water"):Connect(wrap)