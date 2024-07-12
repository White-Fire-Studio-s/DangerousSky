--@
--// Services
local CollectionService = game:GetService("CollectionService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Server = ReplicatedStorage:WaitForChild("Server")

--// Imports
local Wrapper = require(Packages.Wrapper)
local formatNumber = require(ReplicatedStorage.NumberFormatter)

local Display = ReplicatedStorage.Assets.LeaderboardDisplay

--// Cache
local leaderboards = setmetatable({}, { __mode = "k" })

local Leaderboard = {}

local function formatTimer(timer: number)
    local minutes = timer // 60
    local seconds = timer % 60
    local miliseconds = (timer % 1) * 100

    return string.format("%.2d:%.2d.%.2d", minutes, seconds, miliseconds)
end

function Leaderboard.wrap(rbxLeaderboard: Model)

    local self = Wrapper(rbxLeaderboard)

    assert(self.isAcending ~= nil)
    assert(self.statistic)

    local orderedDatastore = DataStoreService:GetOrderedDataStore(self.statistic)
        :: OrderedDataStore

    function self:update()

        local pages = orderedDatastore:GetSortedAsync(self.isAcending, 100)
        local leaders = pages:GetCurrentPage()
        
        for rank, entry in leaders do

            local display = rbxLeaderboard.Display.SurfaceGui.Scroll:FindFirstChild(rank) or self:createDisplay(rank)
            local value = entry.value
            local playerName = Players:GetNameFromUserIdAsync(entry.key)

            display.Player.Text = `@{playerName}`
            display.Value.Text = if self.hours then `{math.floor(value/360)/10 }h` 
                elseif self.timer then formatTimer(value)
                else formatNumber(value)
        end
    end

    function self:createDisplay(rank: number)
        
        local display: Frame = Display:Clone()
        display.Name = rank
        display.BackgroundTransparency = if rank % 2 == 0 then 1 else 0
        display.Parent = rbxLeaderboard.Display.SurfaceGui.Scroll
        display.LayoutOrder = rank

        display.Rank.TextColor3 = 
            if rank == 1 then Color3.fromRGB(255, 255, 0)
            elseif rank == 2 then Color3.fromRGB(207, 207, 207)
            elseif rank == 3 then Color3.fromRGB(226, 90, 22)
            else Color3.fromRGB(255, 255, 255) 

        return display
    end

    --// Create Schemes
    for rank = 1, 100 do
        local display = self:createDisplay(rank)

        display.Rank.Text = `#{rank}`
        display.Player.Text = "unknown"
        display.Value.Text = "0"
    end

    task.delay(10, function()
        repeat

            self:update()
        until not task.wait(60)
    end)

    leaderboards[rbxLeaderboard] = self

    return self
end

--// End

return Leaderboard