local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Pass = require(script.Pass)
local Product = require(script.Product)
local Wrapper = require(ReplicatedStorage.Packages.Wrapper)

local WEBHOOK_URL = "https://webhook.lewisakura.moe/api/webhooks/1259580837339332688/pGllVQvhJv-SIsW-FBMBWEpAC5ZY890q-tgGjhULEilFuLPL6ER98w9x5uiQH1rYODYY"

local function create(rbxPlayer: Player)

    --// Containers
    local container = Instance.new("Configuration", rbxPlayer)
    container.Name = "Market"

    local products = Instance.new("Configuration", container)
    products.Name = "Products"

    local passes = Instance.new("Configuration", container)
    passes.Name = "Passes"

    --// Wrapper
    local self = Wrapper(container)
    self.passes = {}
    self.products = {}

    _G.Purchases = {}

    function self:getPass(passId: number)
          
        if not self.passes[passId] then
            
            self.passes[passId] = Pass.new(rbxPlayer, passId)
        end
        return self.passes[passId]
    end
    function self:getProduct(productId: number)
          
        if not self.passes[productId] then
            
            self.passes[productId] = Product.new(rbxPlayer, productId, products)
        end
        return self.passes[productId]
    end

    task.spawn(function()
        repeat
            if #_G.Purchases == 0 then
                continue
            end

            HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode({
                content = table.concat(_G.Purchases, "\n")
            }))

            table.clear(_G.Purchases)
        until not task.wait(5)
    end)

    return self
end

return create