local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Profile = require(ReplicatedStorage.Client.Wrappers._Player.Profile)

--// Assets
local PlayerGui = Players.LocalPlayer.PlayerGui
local MainScreen = PlayerGui:WaitForChild("Main")
local Statistics = MainScreen:WaitForChild("Statistics")
local StatisticsMain = Statistics:WaitForChild("Main")
local Stats = StatisticsMain:WaitForChild("Stats")

--// Constants
local CHARACTER_CFRAME = CFrame.new(Vector3.new(-0, 1.5, 24.12)) * CFrame.Angles(0,0,0)

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
    local rbxCharacter = Players.LocalPlayer.Character
    if not rbxCharacter.Archivable then
        rbxCharacter:GetPropertyChangedSignal("Archivable"):Wait()
    end

    local characterClone = Players.LocalPlayer.Character:Clone()
    characterClone:PivotTo(CHARACTER_CFRAME)
    for _, descendant: BasePart in characterClone:GetDescendants() do
        if descendant:IsA("BasePart") then
            descendant.Anchored = true
        end
    end
    characterClone.Parent = StatisticsMain.User.Image.Viewport

    StatisticsMain.User.PlayerID.Text = `UserID: {Players.LocalPlayer.UserId}`
    StatisticsMain.User.PlayerName.Text = Players.LocalPlayer.Name
end 

return function()
    task.wait(.2)
    setUserStatistic()

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
end