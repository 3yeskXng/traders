local json = {}

function json.decode(str)
    if type(str) ~= "string" then return nil, "expected string" end
    local pos = 1
    local function skipWhitespace()
        while pos <= #str do
            local c = str:sub(pos, pos)
            if c == ' ' or c == '\t' or c == '\n' or c == '\r' then
                pos = pos + 1
            else
                break
            end
        end
    end

    local function parseValue()
        skipWhitespace()
        if pos > #str then return nil, "unexpected end" end
        local c = str:sub(pos, pos)
        if c == '"' then
            return parseString()
        elseif c == '{' then
            return parseObject()
        elseif c == '[' then
            return parseArray()
        elseif c == 't' then
            if str:sub(pos, pos + 3) == "true" then pos = pos + 4; return true end
            return nil, "expected true"
        elseif c == 'f' then
            if str:sub(pos, pos + 4) == "false" then pos = pos + 5; return false end
            return nil, "expected false"
        elseif c == 'n' then
            if str:sub(pos, pos + 3) == "null" then pos = pos + 4; return nil end
            return nil, "expected null"
        elseif c == '-' or (c >= '0' and c <= '9') then
            return parseNumber()
        end
        return nil, "unexpected character: " .. c
    end

    function parseString()
        if str:sub(pos, pos) ~= '"' then return nil, "expected quote" end
        pos = pos + 1
        local s = {}
        while pos <= #str do
            local c = str:sub(pos, pos)
            if c == '"' then
                pos = pos + 1
                return table.concat(s)
            elseif c == '\\' then
                pos = pos + 1
                if pos > #str then return nil, "unexpected end" end
                local esc = str:sub(pos, pos)
                if esc == '"' or esc == '\\' or esc == '/' then
                    table.insert(s, esc)
                elseif esc == 'b' then table.insert(s, '\b')
                elseif esc == 'f' then table.insert(s, '\f')
                elseif esc == 'n' then table.insert(s, '\n')
                elseif esc == 'r' then table.insert(s, '\r')
                elseif esc == 't' then table.insert(s, '\t')
                elseif esc == 'u' then
                    local hex = str:sub(pos + 1, pos + 4)
                    if #hex < 4 then return nil, "invalid unicode escape" end
                    local cp = tonumber(hex, 16)
                    table.insert(s, utf8 and utf8.char(cp) or string.char(cp))
                    pos = pos + 4
                else
                    table.insert(s, esc)
                end
                pos = pos + 1
            else
                table.insert(s, c)
                pos = pos + 1
            end
        end
        return nil, "unterminated string"
    end

    function parseNumber()
        local start = pos
        if str:sub(pos, pos) == '-' then pos = pos + 1 end
        while pos <= #str and str:sub(pos, pos) >= '0' and str:sub(pos, pos) <= '9' do
            pos = pos + 1
        end
        if pos <= #str and str:sub(pos, pos) == '.' then
            pos = pos + 1
            while pos <= #str and str:sub(pos, pos) >= '0' and str:sub(pos, pos) <= '9' do
                pos = pos + 1
            end
        end
        if pos <= #str and (str:sub(pos, pos) == 'e' or str:sub(pos, pos) == 'E') then
            pos = pos + 1
            if pos <= #str and (str:sub(pos, pos) == '+' or str:sub(pos, pos) == '-') then pos = pos + 1 end
            while pos <= #str and str:sub(pos, pos) >= '0' and str:sub(pos, pos) <= '9' do
                pos = pos + 1
            end
        end
        return tonumber(str:sub(start, pos - 1))
    end

    function parseObject()
        pos = pos + 1
        local obj = {}
        skipWhitespace()
        if str:sub(pos, pos) == '}' then pos = pos + 1; return obj end
        while pos <= #str do
            skipWhitespace()
            local k, err = parseString()
            if not k then return nil, err end
            skipWhitespace()
            if str:sub(pos, pos) ~= ':' then return nil, "expected colon" end
            pos = pos + 1
            local v, err2 = parseValue()
            if not v and err2 ~= "unexpected end" and not (v == nil and err2 == nil) then
                if err2 then return nil, err2 end
            end
            obj[k] = v
            skipWhitespace()
            local c = str:sub(pos, pos)
            if c == '}' then pos = pos + 1; return obj end
            if c ~= ',' then return nil, "expected comma or }" end
            pos = pos + 1
        end
        return nil, "unterminated object"
    end

    function parseArray()
        pos = pos + 1
        local arr = {}
        skipWhitespace()
        if str:sub(pos, pos) == ']' then pos = pos + 1; return arr end
        while pos <= #str do
            local v, err = parseValue()
            if not v and v ~= false and v ~= nil then -- only nil is an error
                if err then return nil, err end
            end
            if v ~= nil or err == nil then
                table.insert(arr, v)
            end
            skipWhitespace()
            local c = str:sub(pos, pos)
            if c == ']' then pos = pos + 1; return arr end
            if c ~= ',' then return nil, "expected comma or ]" end
            pos = pos + 1
        end
        return nil, "unterminated array"
    end

    local result, err = parseValue()
    if not result and err then return nil, err end
    return result
end

function json.encode(val)
    local function encodeValue(v)
        local t = type(v)
        if t == "nil" then
            return "null"
        elseif t == "boolean" then
            return v and "true" or "false"
        elseif t == "number" then
            return tostring(v)
        elseif t == "string" then
            local escaped = v:gsub('\\', '\\\\')
            escaped = escaped:gsub('"', '\\"')
            escaped = escaped:gsub('\b', '\\b')
            escaped = escaped:gsub('\f', '\\f')
            escaped = escaped:gsub('\n', '\\n')
            escaped = escaped:gsub('\r', '\\r')
            escaped = escaped:gsub('\t', '\\t')
            return '"' .. escaped .. '"'
        elseif t == "table" then
            local isArray = true
            local maxKey = 0
            for k in pairs(v) do
                if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
                    isArray = false
                    break
                end
                if k > maxKey then maxKey = k end
            end
            if isArray then
                local parts = {}
                for i = 1, maxKey do
                    table.insert(parts, encodeValue(v[i]))
                end
                return "[" .. table.concat(parts, ",") .. "]"
            else
                local parts = {}
                local keys = {}
                for k in pairs(v) do table.insert(keys, k) end
                table.sort(keys)
                for _, k in ipairs(keys) do
                    table.insert(parts, encodeValue(k) .. ":" .. encodeValue(v[k]))
                end
                return "{" .. table.concat(parts, ",") .. "}"
            end
        end
        return "null"
    end
    return encodeValue(val)
end

return json
