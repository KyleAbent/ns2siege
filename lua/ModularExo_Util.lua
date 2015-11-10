function GetLocal(originalFunction, name)
    local index = 1
    local foundIndex, foundValue = nil, nil
    while true do
        local n, v = debug.getupvalue(originalFunction, index)
        if not n then
            break
        end
        if n == name then
            return v
        end
        index = index + 1
    end
end