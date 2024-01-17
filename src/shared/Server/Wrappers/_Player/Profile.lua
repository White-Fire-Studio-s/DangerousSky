--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ServerPackages = ServerStorage:WaitForChild("Packages")

--// Imports
local ProfileService = require(ServerPackages.ProfileService)
local wrapper = require(Packages.Wrapper)

--// Constants
local MOCK_ENABLED = true

--// Functions
local function isHash(hash)
    return type(hash) == "table" and 
    type(next(hash)) ~= "number" 
end

--// Profile
local ProfileStore = ProfileService.GetProfileStore("_userData", {
    test = 5;
    test3 = 6;
    a = {
        b = 5;
    }
})
if MOCK_ENABLED and RunService:IsStudio() then 
    ProfileStore = ProfileStore.Mock 
end

local Profile = {}

local profiles = setmetatable({}, { __mode = "k" })
local createSubContainers;

function Profile.wrap(container: Folder)
    local rbxPlayer = container:FindFirstAncestorOfClass("Player")
    local profile = ProfileStore:LoadProfileAsync(`id_{rbxPlayer.UserId}`)
    if not profile then return rbxPlayer:Kick() end

    profile:AddUserId(rbxPlayer.UserId)
    profile:Reconcile()
    profile:ListenToRelease(function() warn(profile.Data) end)

    if not rbxPlayer:IsDescendantOf(Players) then
        profile:Release()

        return 
    end

    profiles[rbxPlayer] = profile

    local self = wrapper(container)
    for index, value in profile.Data do self[index] = value end
  
    createSubContainers(self, profile.Data)

    --// Listeners
    container.AttributeChanged:Connect(function(attribute)
        if isHash(profile.Data[attribute]) then
            return
        end

        profile.Data[attribute] = self[attribute]
    end)

    return self
end

function createSubContainers(parentWrapper, data)
    for index, value in data do
        if isHash(value) then
            parentWrapper[index] = Profile._wrapSubcontainer(index, value, parentWrapper)
        end
    end
end

function Profile._wrapSubcontainer(name, data, parentWrapper)
    local subContainerFolder = Instance.new("Folder", parentWrapper.roblox)
    subContainerFolder.Name = name

    local self = wrapper(subContainerFolder)
    for index, value in data do self[index] = value end
        
    createSubContainers(subContainerFolder, data)

    subContainerFolder.AttributeChanged:Connect(function(attribute)
        data[attribute] = self[attribute]
    end)

    return self
end

function Profile.get(rbxPlayer: Player)
    return profiles[rbxPlayer]
end

return Profile