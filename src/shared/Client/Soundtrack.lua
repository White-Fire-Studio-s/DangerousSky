local Workspace = game:GetService("Workspace")
local SoundtrackFolder = Workspace:WaitForChild("Soundtrack")

while true do
    for _, music: Sound in SoundtrackFolder:GetChildren() do
        music:Play()
        warn(`PLAYING {music.Name}`)

        music.Ended:Wait()
    end
end

return nil