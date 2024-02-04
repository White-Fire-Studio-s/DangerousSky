local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Profile = require(ReplicatedStorage.Client.Wrappers._Player.Profile)

--// Assets
local PlayerGui = Players.LocalPlayer.PlayerGui
local MainScreen = PlayerGui:WaitForChild("Main")
local Statistics = MainScreen:WaitForChild("Statistics")
local StatisticsMain = Statistics:WaitForChild("Main")
local Stats = StatisticsMain:WaitForChild("Stats")

--// Constants
local CHARACTER_CFRAME = CFrame.new(
    -136.716, 24.52, -124.884
)

--// Vars
local formatNumber = require(ReplicatedStorage.NumberFormatter)

local function convertToHours(amount: number)
    
    return `{math.floor(amount / 36)/100}h`
end

local function convertTime(amount: number)
    
    local minutes = math.floor(amount / 60)
    local seconds = amount % 60
    local _,miliseconds = math.modf(amount)
    
    miliseconds = math.round(miliseconds * 100)
    
    return string.format("%.2i:%.2i:%0.2i", minutes, seconds, miliseconds)
end

local function setStatistic(profile, statistic: string, formatter: (number) -> string)
    
    local value = profile.Statistics[statistic]
    
    Stats[statistic].Value.Label.Text = formatter(value)
end

local function setUserStatistic()

    local userDescription = Players:GetHumanoidDescriptionFromUserId(Players.LocalPlayer.UserId);
    local dummy = Players:CreateHumanoidModelFromDescription(userDescription, Enum.HumanoidRigType.R6, Enum.AssetTypeVerification.ClientOnly)


    dummy:PivotTo(CHARACTER_CFRAME)
    dummy.Parent = StatisticsMain.User.Image.Viewport.WorldModel

    local animations = (dummy.Humanoid.Animator :: Animator):GetPlayingAnimationTracks()

    for _,animations: AnimationTrack in animations do
        animations:Stop()
        animations:Destroy()
    end
end 

return function()

    local statisticsFormatter = {
        Wins = formatNumber;
        Deaths = formatNumber;
        BestTime = convertTime;
        TimePlayed = convertToHours
    }
    local playerProfile = Profile.get(Players.LocalPlayer)
    
    for statistic, formatter in statisticsFormatter do

        setStatistic(playerProfile, statistic, formatter)
        
        playerProfile.Statistics:listenChange(statistic):connect(function()
            setStatistic(playerProfile, statistic, formatter)
        end)
    end

    setUserStatistic()
end