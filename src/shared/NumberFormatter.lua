local sufixes = { "k", "m", "b", "t", "qa", "qi", "sx", "sp", "oc", "nn", "dc", "ud", "dd" }

local function formatNumber(amount: number)
    
    if amount == 0 then return '0' end
    if amount < 1 then return tostring(amount) end

    local cases = math.log10(amount)
    local unit = math.floor(cases / 3)
    
    return string.format("%.02f", amount/10^(unit*3))
        :gsub("%.0+$", "")
        .. (sufixes[unit] or "")
end

return formatNumber