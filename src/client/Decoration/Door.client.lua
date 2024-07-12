local CollectionService = game:GetService("CollectionService")

local function wrap(door: MeshPart & { ClickDetector: ClickDetector })

    local clickDetector = door:WaitForChild("ClickDetector")

    clickDetector.MouseClick:Connect(function()
        workspace.Soundtrack.SFX.Door:Play()
    end)
end

for _, door in CollectionService:GetTagged("HouseDoor") do
    wrap(door)
end

CollectionService:GetInstanceAddedSignal("HouseDoor"):Connect(wrap)

return {}