function love.load()
    -- Test correct decode API: love.data.decode(container, data, format)
    local data = love.filesystem.read("data/goods.json")
    local ok1, result1 = pcall(love.data.decode, "string", data, "json")
    print("DECODE(string, data, json): ok=" .. tostring(ok1) .. " type=" .. type(result1))
    if type(result1) == "table" then
        print("  Items: " .. #result1)
        for i, v in ipairs(result1) do
            if i <= 2 then print("  [" .. i .. "] " .. tostring(v.id) .. " = " .. tostring(v.name)) end
        end
    end

    -- Test encode
    local ok2, result2 = pcall(love.data.encode, "json", {test = 42})
    print("ENCODE(json, tbl): ok=" .. tostring(ok2) .. " type=" .. type(result2))

    local ok3, result3 = pcall(love.data.encode, "json", {test = 42}, "string")
    print("ENCODE(json, tbl, string): ok=" .. tostring(ok3) .. " type=" .. type(result3))
    if type(result3) == "string" then
        print("  Result: " .. result3)
    end

    love.event.quit()
end
