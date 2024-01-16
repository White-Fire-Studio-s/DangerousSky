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

--// Profile
local ProfileStore = ProfileService.GetProfileStore("userData", {
    test = 5;
    test3 = 6;
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
    profile:ListenToRelease(function() rbxPlayer:Kick() end)

    if not rbxPlayer:IsDescendantOf(Players) then
        profile:Release()

        return 
    end

    profiles[rbxPlayer] = profile

    local self = wrapper(container)
        :_syncAttributes(profile.Data)

    createSubContainers(self, profile.Data)

    return self
end

local function createSubContainers(parent, data)
    for index, value in data do
        if 
            type(value) == "table" and 
            type(next(value)) == "string" 
        then
            parent[index] = Profile._wrapSubcontainer(index, value, parent)
        end
    end
end

function Profile._wrapSubcontainer(name, value, parent)
    local subContainerFolder = Instance.new("Folder", parent)
    subContainerFolder.Name = name

    local self = wrapper(subContainerFolder)
        :_syncAttributes(value)

    createSubContainers(self, value)

    return self
end

function Profile.get(rbxPlayer: Player)
    return profiles[rbxPlayer]
end

return Profile