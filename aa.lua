local prev = workspace.TestStage2
local sample = { workspace.TestStage2, workspace.TestStage }

for i = 1, 8 do
    local a = sample[if i % 2 == 0 then 1 else 2]:Clone()
    a.Parent = workspace

    local angle = i * 60

    local prevEndPosition = prev.End.Position

    local startOffset = a.Start.Position - a.PrimaryPart.Position
    local newStartPosition = prevEndPosition - startOffset

    local rotation = CFrame.Angles(0, math.rad(angle), 0)
    a:PivotTo(CFrame.new(newStartPosition) * rotation)
    
    prev = a
end
