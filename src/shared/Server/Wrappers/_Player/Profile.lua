--// Services
local DataStoreService = game:GetService("DataStoreService")
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

local Wrapper = require(Packages.Wrapper)

--// Cache
local profiles = setmetatable({}, { __mode = "k" })

--// Profile
local Profile = {}

local ProfileStore = ProfileService.GetProfileStore("_userData", ProfileSettings.Scheme)
if ProfileSettings.Mock then ProfileStore = ProfileStore.Mock end

local function isDict(data)
    return type(data) == "table" and type(next(data)) == "string"
end

_G.ORDERED_STATISTIC = setmetatable({}, { __mode = "k" })

function Profile.wrap(rbxPlayer: Player)

    local profileContainer = Instance.new("ObjectValue")
    profileContainer.Name = "Profile"
    
    local self = Wrapper(profileContainer)

    self.isLoading = true
    
    --// Releases
    local releases = {}

    function releases.kickPlayer()
        return rbxPlayer:Kick()
    end

    function releases.saveLeaderboard()
        
        for _,data: {store: OrderedDataStore, value: number } in _G.ORDERED_STATISTIC[rbxPlayer] do

            data.store:SetAsync(rbxPlayer.UserId, data.value // 1)
        end
    end

     --// Load Profile
    local profile = ProfileStore:LoadProfileAsync(`id_{rbxPlayer.UserId}`)
    if not profile then return rbxPlayer:Kick() end

    profile:AddUserId(rbxPlayer.UserId)
    profile:Reconcile()
    profile:ListenToRelease(function() for _, r in releases do r() end end)
    
    if not rbxPlayer:IsDescendantOf(Players) then return profile:Release() end
    
    self:_applyAttributes(profile.Data)
    self.roblox.AttributeChanged:Connect(function(attribute: string)
        if not profile[attribute] then
            return
        end
        
        profile.Data[attribute] = self[attribute] 
    end)
    
    rbxPlayer.AncestryChanged:Connect(function()
        profile:Release()
    end)
    
    --// Functions
    local create;
    local function wrap(name: string, data: { [string]: any }, parent)
        
        local subContainer = Instance.new("ObjectValue", parent.roblox)
        subContainer.Name = name;
        
        local self = Wrapper(subContainer)
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


    profiles[rbxPlayer] = self
    
    profileContainer.Parent = rbxPlayer
    self.isLoading = false

    _G.ORDERED_STATISTIC[rbxPlayer] = { 
        ["Gems"] = { store = DataStoreService:GetOrderedDataStore("Gems"), value = self.Statistics.Gems };
        ["Deaths"] = { store = DataStoreService:GetOrderedDataStore("Deaths"), value = self.Statistics.Deaths };
        ["Wins"] = { store = DataStoreService:GetOrderedDataStore("Wins"), value = self.Statistics.Wins };
        ["BestTime"] = { store = DataStoreService:GetOrderedDataStore("BestTime"), value = self.Statistics.BestTime };
        ["TimePlayed"] = { store = DataStoreService:GetOrderedDataStore("TimePlayed"), value = self.Statistics.TimePlayed };
    }

    return self
end

function Profile.get(rbxPlayer: Player)
    return profiles[rbxPlayer] or Profile.wrap(rbxPlayer)
end

return Profile