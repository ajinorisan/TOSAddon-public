local json = require("json")
local out={}
local path="C:\Codes\Lua\tos_google_translate\send.json"
local output = io.open(path, "r", "Shift_JIS")
local content = output:read("*all")
output:close()
out = json.decode(content)
for i, entry in ipairs(out) do
    print("Entry " .. i .. ":")
    for key, value in pairs(entry) do
        print("\t" .. key .. ": " .. tostring(value))
    end
end
--print(out)
