local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(script.Parent.Components.Button)
local Zap = require(ReplicatedStorage.Zap)

--// Assets
local PlayerGui = Players.LocalPlayer.PlayerGui
local MainScreen = PlayerGui:WaitForChild("Main")
local Store = MainScreen:WaitForChild("Store")
local StoreMain = Store:WaitForChild("Main")
local Codes = StoreMain:WaitForChild("Codes")

return function ()
    
    local buttonReedem = Button.get(Codes.Reedem)

    Codes.TextBox.Focused:Connect(function()
        Codes.Status.Visible = false
    end)

    buttonReedem.Clicked:connect(function()

        local status = Zap.ReedemCode.call(Codes.TextBox.Text:gsub("%s+", ""))  
        
        Codes.Status.Visible = true

        if status == "Invalid" then
            Codes.Status.Text = "Invalid Code"
            Codes.Status.TextColor3 = Color3.fromRGB(255, 70, 70)
        elseif status == "Expired" then
            Codes.Status.Text = "Code Expired"
            Codes.Status.TextColor3 = Color3.fromRGB(255, 70, 70)
        elseif status == "Used" then
            Codes.Status.Text = "Code Already Redeemed"
            Codes.Status.TextColor3 = Color3.fromRGB(255, 70, 70)
        else
            Codes.Status.Text = "Code Redeemed!"
            Codes.Status.TextColor3 = Color3.fromRGB(0, 170, 255)
        end
    end)
end