function love.load()
    -- Test 1: Can we read the file?
    local data, size = love.filesystem.read("data/goods.json")
    if data then
        print("READ OK: " .. #data .. " bytes, size=" .. tostring(size))
        print("First 50 chars: " .. data:sub(1, 50))
    else
        print("READ FAILED: no data")
    end

    -- Test 2: Try love.data.decode
    if data then
        local ok, result = pcall(love.data.decode, "json", data)
        print("DECODE pcall ok=" .. tostring(ok))
        if ok then
            print("Result type: " .. type(result))
            if type(result) == "table" then
                print("Table entries: " .. #result)
                for i, v in ipairs(result) do
                    print("  [" .. i .. "] id=" .. tostring(v.id) .. " name=" .. tostring(v.name))
                    if i >= 3 then break end
                end
            else
                print("Result value: " .. tostring(result))
            end
        else
            print("DECODE ERROR: " .. tostring(result))
        end
    end

    -- Test 3: Try with simple JSON
    local simple_ok, simple_result = pcall(love.data.decode, "json", '{"test": 123}')
    print("SIMPLE JSON: ok=" .. tostring(simple_ok) .. " result=" .. tostring(simple_result))

    -- Test 4: Try with a file from the data dir using love.filesystem
    print("CWD: ", love.filesystem.getWorkingDirectory())
    local files = love.filesystem.getDirectoryItems("data")
    print("Files in data/: " .. #files)
    for _, f in ipairs(files) do print("  " .. f) end

    love.event.quit()
end
