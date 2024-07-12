--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage") :: ReplicatedStorage & { Round: Configuration}
local RunService = game:GetService("RunService")

--// Imports
local Replication = require(ReplicatedStorage.Packages.Replication)

--// Object
local server = Replication.await(workspace.SpecialObjects)

local function trait(self)

    if ReplicatedStorage.Round:GetAttribute("Invincibility") then
        return
    end

    self.damageDelay = self.damageDelay or 0.5
    
    local lastHit = 0
    local connection = RunService.RenderStepped:Connect(function()

        if os.clock() - lastHit < self.damageDelay then return end

        local params = OverlapParams.new()
        params.FilterDescendantsInstances = { Players.LocalPlayer.Character }
        params.FilterType = Enum.RaycastFilterType.Include
        params.MaxParts = 1

        local touchingParts = workspace:GetPartBoundsInBox(self.roblox.CFrame, self.roblox.Size, params)

        if touchingParts[1] then

            server:invokeKillbrickHitAsync(self.originalObject, Players.LocalPlayer.Character)

            lastHit = os.clock()
        end
    end)

    self:_host(connection)

    self:_host(ReplicatedStorage.Round:GetAttributeChangedSignal("Invincibility"):Once(function()
        if ReplicatedStorage.Round:GetAttribute("Invincibility") then
            connection:Disconnect()
        end
    end))
end

return trait