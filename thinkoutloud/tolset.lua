-- vim:ts=4:sw=4:sts=4:et:
-- Flakey Set implementation

TOLSet = {}
TOLSet.__index = TOLSet

function TOLSet.new(t)
    local newset = {}
    setmetatable(newset, TOLSet)
    if t then
        for k,v in pairs(t) do
            newset[v] = true
        end
    end
    return newset
end

function TOLSet.add(set, element)
    set[element] = true
end

function TOLSet.remove(set, element)
    set[element] = nil
end

function TOLSet.intersection(set1, set2)
    local result = TOLSet.new()
    for k in pairs(set1) do
        result[k] = set2[k]
    end
    return result
end

function TOLSet.union(set1, set2)
    local result = TOLSet.new()
    for k in pairs(set1) do result[k] = true end
    for k in pairs(set2) do result[k] = true end
    return result
end

function TOLSet.toList(set)
    local result = {}
    for k in pairs(set) do
        table.insert(result, k)
    end
    return result
end
