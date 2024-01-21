local tbl = table.create(1000, workspace)
local tbl2 = {}

local cock1 = os.clock()
table.move(tbl, 1, #tbl, 1, tbl2)
local cock2 = os.clock()
warn(cock2 - cock1)
warn(#tbl2, #tbl)