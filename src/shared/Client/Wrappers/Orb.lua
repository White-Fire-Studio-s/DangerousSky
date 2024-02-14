--// Services
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Client = ReplicatedStorage:WaitForChild("Client")
local Wrappers = Client:WaitForChild("Wrappers")

--// Imports
local Wrapper = require(Packages.Wrapper)
local Replication = require(Packages.Replication)

--// Module
local Orb = {}

local orbs = setmetatable({}, { __mode = "k" })

function Orb.wrap(orb: Model)
    local self = Wrapper(orb)
    local server = Replication.await(orb)

    local cframe = orb.WorldPivot
    local lifetime = 0

    self:_host(task.spawn(function()
        repeat
            lifetime += task.wait()

            local orbCfame = cframe
                * CFrame.new(0, math.sin(lifetime), 0)
                * CFrame.Angles(0, lifetime, 0)

            local _,orbSize = orb:GetBoundingBox()

            orb:PivotTo(orbCfame)

            --// Hitbox
            local overlapParams = OverlapParams.new()
            overlapParams.FilterType = Enum.RaycastFilterType.Include
            overlapParams.FilterDescendantsInstances = { Players.LocalPlayer.Character }
            overlapParams.MaxParts = 1

            local characterPart = Workspace:GetPartBoundsInBox(orbCfame, orbSize, overlapParams)
            if not characterPart[1] then
                continue
            end

            server:invokeCollectAsync(lifetime)

        until self.collected
    end))

    self:_host(self:listenChange("collected"):connect(function()
        
        Workspace.Soundtrack.SFX.Collect:Play()

        local fade = 0
        repeat fade += task.wait()/0.2
            if fade > 1 then fade = 1 end

            orb:ScaleTo(math.max(1 - fade, 0.01))
        until fade == 1

        self:destroy()
    end))

    orbs[orb] = self

    return self
end


--// Listeners
for _, orb in CollectionService:GetTagged("orb") do Orb.wrap(orb) end
CollectionService:GetInstanceAddedSignal("orb"):Connect(Orb.wrap)

return Orb