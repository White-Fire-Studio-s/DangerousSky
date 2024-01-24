--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

--// Imports
local Entity = require(Packages.Entity)
local Wrapper = require(Packages.Wrapper)

--// Profile
return Entity.trait("Profile", function(self, rbxPlayer: Player)
    if rbxPlayer ~= Players.LocalPlayer then
        return
    end

    --// Loader
    if self.isLoading then
        self:listenChange("isLoading"):await()
    end

    --// Private
    local function computeSubData(dataWrapper)
        for _, subData: ObjectValue in dataWrapper.roblox:GetChildren() do
            if dataWrapper[subData.Name] then
                continue
            end
            local subDataWrapper = self:_host(Wrapper(subData))
            computeSubData(subDataWrapper)


            dataWrapper[subData.Name] = subDataWrapper
        end
    end

    computeSubData(self)
    self:_host(self.roblox.ChildAdded:Connect(function()
        computeSubData(self)
    end))

    return self
end)