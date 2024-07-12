local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local SIZE_DECREASE = Vector3.new(.8,.8,.8)
local TWEEN_INFO = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, true)

local function wrap(duck: MeshPart & { ClickDetector: ClickDetector })

    local reducedSize = duck.Size  * SIZE_DECREASE
    local clickDetector = duck:WaitForChild("ClickDetector")

    local tween = TweenService:Create(duck, TWEEN_INFO, { Size = reducedSize })

    clickDetector.MouseClick:Connect(function()
        tween:Play()
        workspace.Soundtrack.SFX.Quack:Play()
    end)
end

for _, duck in CollectionService:GetTagged("Duck") do
    wrap(duck)
end

CollectionService:GetInstanceAddedSignal("Duck"):Connect(wrap)

return {}