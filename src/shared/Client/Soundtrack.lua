local Workspace = game:GetService("Workspace")
local SoundtrackFolder = Workspace:WaitForChild("Soundtrack")

while true do
    for _, music: Sound in SoundtrackFolder.Musics:GetChildren() do
        music:Play()
        music.Ended:Wait()
    end
end

return nil