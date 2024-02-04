--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

--// Imports
local Wrapper = require(Packages.Wrapper)
local Replication = require(Packages.Replication)

--// Cache
local profiles = setmetatable({}, { __mode = "k" })

--// Profile
local Profile = {}

function Profile.wrap(rbxPlayer: Player)
    
    if rbxPlayer ~= Players.LocalPlayer then
        return
    end

    local profileContainer = rbxPlayer:WaitForChild("Profile")
    
    local self = Wrapper(profileContainer)
    
    --// Private
    local function computeSubData(dataWrapper)
        
        for _, subData: ObjectValue in dataWrapper.roblox:GetChildren() do
            
            if dataWrapper[subData.Name] then
                continue
            end
            
            if not subData:IsA("ObjectValue") then
                continue
            end
            
            local subDataWrapper = Wrapper(subData)
            local server = Replication.wrap(subData)
            
            computeSubData(subDataWrapper)
            
            dataWrapper[subData.Name] = setmetatable({}, {
                __index = function(_, index: string)
                    return subDataWrapper[index] or server[index]
                end
            })
        end
    end
    
    computeSubData(self)
    self:_host(self.roblox.ChildAdded:Connect(function()
        computeSubData(self)
    end))
    
    profiles[rbxPlayer] = self
    
    return self
end

function Profile.get(rbxPlayer: Player)
    return profiles[rbxPlayer] or Profile.wrap(rbxPlayer)
end

return Profile