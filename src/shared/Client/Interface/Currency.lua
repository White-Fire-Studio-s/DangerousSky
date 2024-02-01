--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Profile = require(ReplicatedStorage.Client.Wrappers._Player.Profile)

--// Assets
local PlayerGui = Players.LocalPlayer.PlayerGui
local MainScreen = PlayerGui:WaitForChild("Main")
local Currency = MainScreen:WaitForChild("Currency")
local CurrencyLabel = Currency:WaitForChild("Label")

--// Vars
local playerProfile = Profile.get(Players.LocalPlayer)

local tweenHandler = Instance.new("NumberValue")
local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quint)

--// Methods
local formatNumber = require(ReplicatedStorage.NumberFormatter)

local function setCurrency(amount: number)
    local tween = TweenService:Create(tweenHandler, tweenInfo, {
        Value = amount
    })
    
    tween:Play()
    tween.Completed:Once(function(playbackState)
        if playbackState == Enum.PlaybackState.Cancelled then
            return
        end
        
        CurrencyLabel.Text = formatNumber(tweenHandler.Value)
    end)
end

tweenHandler.Changed:Connect(function()
    CurrencyLabel.Text = formatNumber(tweenHandler.Value)
end)

--// Init
return function ()
    setCurrency(playerProfile.Clouds)
    
    playerProfile:listenChange("Clouds"):connect(setCurrency)
end