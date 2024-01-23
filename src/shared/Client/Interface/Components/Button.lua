--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")

--// Imports
local wrapper = require(Packages.Wrapper)
local Entity = require(Packages.Entity)
local Frame = require(script.Parent.Frame)

--// Constants
local DECREASE_TWEENINFO = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, true)
local INCREASE_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Quint)

--// Cache
local buttonGroups = setmetatable({}, {
    __index = function(self: { [string]: { [Button]: boolean } }, groupName: string)
        self[groupName] = setmetatable({}, { __mode = "k" })

        return self[groupName]
    end
})

type Button = TextButton | ImageButton

return Entity.trait("button", function(self, button: Button)
    local leastClick = 0
    local originalSize = button.Size

    local increment = 1.05 
    local increasedSize = UDim2.fromScale(originalSize.X.Scale * increment, originalSize.Y.Scale * increment)

    local decrement = 0.95 
    local decreasedSize = UDim2.fromScale(originalSize.X.Scale * decrement, originalSize.Y.Scale * decrement)

    local originalTween = TweenService:Create(button, INCREASE_TWEENINFO, { Size = originalSize })
    local hoverTween = TweenService:Create(button, INCREASE_TWEENINFO, { Size = decreasedSize })
    local clickTween = TweenService:Create(button, DECREASE_TWEENINFO, { Size = increasedSize })

    local opens = button:FindFirstChild("Opens")
    local closes = button:FindFirstChild("Closes")

    self.group = button:GetAttribute("group") or "main"

    function self:onClick()
        if os.clock() - leastClick <= .2 then
            return
        end

        --// Button Tween
        clickTween:Play()

        --// Frame Tween
        if opens then
            local frame = Frame.get(opens.Value)

            if frame.isOpen then
                frame:close()
            else
                frame:open()
            end
        end

        if closes then
            local frame = Frame.get(closes.Value)
            frame:close()
        end

        leastClick = os.clock()
    end

    button.MouseButton1Click:Connect(function() self:onClick() end)

    if button:GetAttribute("hoverEnabled") then
        button.MouseEnter:Connect(function() hoverTween:Play() end)
        button.MouseLeave:Connect(function() originalTween:Play() end)
    end
end)