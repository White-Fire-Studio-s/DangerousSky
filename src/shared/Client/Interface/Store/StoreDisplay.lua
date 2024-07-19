--// Services
local CollectionService = game:GetService("CollectionService")

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Assets
local Packages = ReplicatedStorage:WaitForChild("Packages")

--// Imports
local Wrapper = require(Packages.Wrapper)
local Button = require(script.Parent.Parent.Components.Button)
local Zap = require(ReplicatedStorage.Zap.Client)
local Replication = require(ReplicatedStorage.Packages.Replication)

local function wrap(storeDisplay: Frame)

    local self = Wrapper(storeDisplay)
    local buyButton = Button.get(storeDisplay.Buy)

    function self:set(storeItem: Wrapper.wrapper<any>)

        if self.Name == storeItem.DisplayName then return end

        local image = storeItem.roblox:FindFirstChildOfClass("ImageLabel")
        local viewportFrame = storeItem.roblox:FindFirstChildWhichIsA("ViewportFrame")

        storeDisplay.DisplayName.Text = storeItem.DisplayName
        storeDisplay.Price.Text = `$ {storeItem.DisplayPrice}`

        self.Name = storeItem.DisplayName
        self.Type = storeItem.Type
        self.GamepassId = storeItem.GamepassId

        storeDisplay.ImageDisplay.Image = if image then image.Image else ""
        
        storeDisplay.ImageDisplay.Viewport:ClearAllChildren()

        if viewportFrame then
            for _, part in viewportFrame:GetChildren() do
                part:Clone().Parent = storeDisplay.ImageDisplay.Viewport
            end
        end
    end

    local canBuy = true

    buyButton.Clicked:connect(function()
        if not (self.Name and self.Type) then 
            return
        end

        if not canBuy then return end

        if self.Type == "Product" then

            local Market = Players.LocalPlayer:WaitForChild("Market")
            local Products = Market:WaitForChild("Products")

            local product = Products:WaitForChild(self.Name)

            MarketplaceService:PromptProductPurchase(Players.LocalPlayer, product:GetAttribute("id"))

            return
        elseif self.Type == "Gamepass" then

            return MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, self.GamepassId)
        end

        Zap.StorePurchase.fire({ itemName = self.Name, type = self.Type })
    end)

    return self
end

local storeDisplay = Players.LocalPlayer.PlayerGui:FindFirstChild("StoreDisplay", true)

return wrap(storeDisplay)