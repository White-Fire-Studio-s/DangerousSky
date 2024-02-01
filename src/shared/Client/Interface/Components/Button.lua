--// Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")

--// Imports
local Entity = require(Packages.Entity)
local Wrapper = require(Packages.Wrapper)
local Frame = require(script.Parent.Frame)

--// Constants
local DECREASE_TWEENINFO = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, true)
local INCREASE_TWEENINFO = TweenInfo.new(0.2, Enum.EasingStyle.Quint)

--// Cache
local buttons = setmetatable({}, { __mode = "k" })

--// Module
local Button = {}

function Button.wrap(button: TextButton | ImageButton)
    local self = Wrapper(button)
    
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
        
        Workspace.Soundtrack.SFX.Click:Play()
        
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
    
    --// Listeners
    button.MouseButton1Click:Connect(function() self:onClick() end)
    
    if button:GetAttribute("hoverEnabled") then
        button.MouseEnter:Connect(function() hoverTween:Play() end)
        button.MouseLeave:Connect(function() originalTween:Play() end)
    end
    
    buttons[button] = self
    
    return self
end

function Button.get(button: TextButton | ImageButton)
    return buttons[button] or Button.wrap(button)
end

--// Loader
CollectionService:GetInstanceAddedSignal("button"):Connect(Button.get)
for _, button in CollectionService:GetTagged("button") do
    Button.get(button)
end

return Button