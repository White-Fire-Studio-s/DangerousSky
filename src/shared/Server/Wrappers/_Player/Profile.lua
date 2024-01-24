--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local ServerPackages = ServerStorage:WaitForChild("Packages")
local Configuration = ReplicatedStorage:WaitForChild("Configuration")

--// Imports
local ProfileService = require(ServerPackages.ProfileService)
local ProfileSettings = require(Configuration.Profile)

local wrapper = require(Packages.Wrapper)
local Entity = require(Packages.Entity)
local Signal = require(Packages.Signal)

--// Profile
local ProfileStore = ProfileService.GetProfileStore("_userData", ProfileSettings.Scheme)
if ProfileSettings.Mock then ProfileStore = ProfileStore.Mock end

local function isDict(data)
    return type(data) == "table" and type(next(data)) == "string"
end

return Entity.trait("Profile", function(self, rbxPlayer: Player)
    --// Load Profile
    local profile = ProfileStore:LoadProfileAsync(`id_{rbxPlayer.UserId}`)
    if not profile then return rbxPlayer:Kick() end

    self.isLoading = true
    
    local releaseSignal = Signal.new("profileReleased")

    profile:AddUserId(rbxPlayer.UserId)
    profile:Reconcile()
    profile:ListenToRelease(function() releaseSignal:_tryEmit(); rbxPlayer:Kick() end)

    if not rbxPlayer:IsDescendantOf(Players) then return profile:Release() end

    self:_applyAttributes(profile.Data)
    self.roblox.AttributeChanged:Connect(function(attribute: string)
         profile[attribute] = self[attribute] 
    end)

    rbxPlayer.AncestryChanged:Connect(function()
        profile:Release()
    end)

    --// Methods
    function self:listenToRelease(callback)
        releaseSignal:once(callback)
    end
    
    --// Functions
    local create;
    local function wrap(name: string, data: { [string]: any }, parent)
        
        local subContainer = Instance.new("ObjectValue", parent.roblox)
        subContainer.Name = name;

        local self = wrapper(subContainer)
        self:_applyAttributes(data)

        subContainer.AttributeChanged:Connect(function(attribute: string)
            data[attribute] = self[attribute] 
        end)

       create(self, data)

       return self
    end
    function create(parentWrapper, data: { [string]: any })

        for index, value in data do
            if isDict(value) then
                parentWrapper[index] = wrap(index, value, parentWrapper)
            end
        end
    end

    create(self, profile.Data)

    self.isLoading = false
    return
end)