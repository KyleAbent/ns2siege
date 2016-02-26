// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua/HotloadTools.lua
//
// Created by Mats Olsson (mats.olsson@matsotech.se)
//
// -----------------------------------
//
// Useful tools for the hotloading-console
// 

local Hotload = Hotload or { } 
// we are working in a console environment - make hotload tools easy to access
ht = Hotload

// save replaced methods in Hotload.orginal[classOrMixinName][functionName]
Hotload.original = Hotload.original or {}

// save locals for a given file
Hotload.locals = Hotload.locals or {}

//
// Analyze the given class, ie dump out all its fields and methods
//
function Hotload.Analyze(className)
    local keys = {}
    local cTable = _G[className]
    if not cTable then
        Log("%s: not found", className)
    else
        for key in pairs(cTable) do table.insert(keys, key) end
        table.sort(keys)
        Log("Contents of %s: #########################", className)
        for i,key in ipairs(keys) do 
            Log("%40s : %s", key, cTable[key])
        end
    end
end

//
// Replace the functionName with newFunction in the classOrMixinName class
//
function Hotload.ReplaceStatic(classOrMixinName, functionName, newFunction)
    local cTable = _G[classOrMixinName]
    if not cTable then
        Log("%s is not a class", classOrMixinName)
        return false
    end
    if not cTable[functionName] then
        Log("%s is not a function in %s", functionName, classOrMixinName)
        return false
    end
    local origTable = Hotload.original[classOrMixinName]
    if not origTable then
        origTable = {}
        Hotload.original[classOrMixinName] = origTable
    end
    if not origTable[functionName] then
        origTable[functionName] = cTable[functionName]
        Log("%s: saved original %s (%s)", classOrMixinName, functionName, cTable[functionName])
    end
    Log("%s: replacing %s (%s) with %s", classOrMixinName, functionName, cTable[functionName], newFunction)
    cTable[functionName] = newFunction
    return true
end

//
// Restore the original functionName for the classOrMixin
//
function Hotload.RestoreStatic(classOrMixinName, functionName)
    local cTable = _G[classOrMixinName]
    local oTable = Hotload.original[classOrMixinName]
    if not cTable then
        Log("%s is not a class", classOrMixinName)
        return nil
    end
    if not oTable then
        Log("%s has no replacements", classOrMixinName)
        return nil
    end
    if not oTable[functionName] then
        Log("%s has not been replaced in %s", functionName, classOrMixinName)
        return nil
    end 
    Log("%s: restored %s with %s", classOrMixinName, functionName, oTable[functionName])
    cTable[functionName] = oTable[functionName]
    return oTable[functionName]
end

//
// Execute the mapFunction for all entities that match the class/mixin
//
function Hotload.ForAll(classOrMixinName, mapFunction)
    local isMixin = StringEndsWith(classOrMixinName,"Mixin") 
    local mixinType = _G[classOrMixinName].type
    local ents = nil
    if isMixin then
        ents = Shared.GetEntitiesWithTag(mixinType)
    else
        ents = Shared.GetEntitiesWithClassname(classOrMixinName)
    end
    for _, ent in ientitylist(ents) do
        mapFunction(ent)
    end
end

// generic replace in objects class - internal 
local function ReplaceInObjects(classOrMixinName, functionName, newFunction, actionName)
    local isMixin = StringEndsWith(classOrMixinName,"Mixin") 
    local mixinType = _G[classOrMixinName].type
    local ents = nil
    local nameToReplace = nil
    if isMixin then
        ents = Shared.GetEntitiesWithTag(mixinType)
        nameToReplace = mixinType .. ":" .. functionName
    else
        ents = Shared.GetEntitiesWithClassname(classOrMixinName)
        nameToReplace = classOrMixinName .. ":" .. functionName
    end

    for _, ent in ientitylist(ents) do
        // check if this method is a mixin method with multiple sub-functions (see MixinUtility.lua)
        local nameTable = ent[functionName .. "__functionNames"]
        local functionsTable = ent[functionName .. "__functions"]
        local traceTable = gTraceTables[ent:GetClassName() .. ":" .. functionName ]
        if nameTable then
            // mixin, find which mixin slot
            for i,name in ipairs(nameTable) do
                if name == nameToReplace then
                    Log("%s: %s(mixin) %s to %s", ent, actionName, name, newFunction)
                    functionsTable[i] = newFunction
                end
            end
            // the mixin-function is created as a lua C-closure for speed (which copies out the data),
            // so we need to re-register it.
            ent[functionName] = Mixin.RegisterFunction(functionsTable, nameTable, traceTable)
        else
            // not a mixin, do we have it at all?
            local func = ent[functionName]
            if ent[functionName] then
                // replace it directly
                Log("%s: %s %s to %s", ent, actionName, functionName, newFunction)
                ent[functionName] = newFunction
            else
                Log("%s: %s missing function %s", ent, actionName, newFunction)
                ent[functionName] = newFunction
            end
        end
    end
end

//
// Replace the given function for current and future instances of the given class/mixin
//
function Hotload.Replace(classOrMixinName, functionName, newFunction)
    if Hotload.ReplaceStatic(classOrMixinName,functionName,newFunction) then
        ReplaceInObjects(classOrMixinName, functionName, newFunction, "replace")
    end
end

//
// Restore the original method in the current class or mixin
//
function Hotload.Restore(classOrMixinName, functionName)
    local origFunction = Hotload.RestoreStatic(classOrMixinName,functionName)
    if origFunction then
        ReplaceInObjects(classOrMixinName, functionName, origFunction, "restore")
    end
end

//
// Insert this at the end of any file that you intend to work with. It stores
// away all top-level locals from that file, allowing you to access them using
// ht.locals[key][localname]. 
//
// As the most common way is to setup your toplevel local namespace the same
// as the file you are working on, there is a convinience function DumpLocals()
// that writes out something you can copy into your hotloading file.
//
function Hotload.StoreLocals(key)
    Hotload.locals[key] = Hotload.locals[key] or {}
    local i = 1
    while true do
        local name, value = debug.getlocal(2, i)
        if name then
            Hotload.locals[key][name] = value
            // Log('%-30s = %s]', name, value)
        else
            break
        end
        i = i + 1
    end
end

// dump all locals stored with the given key
function Hotload.DumpLocals(key)
    local sorted = {}
    for k,v in pairs(Hotload.locals[key]) do
        table.insert(sorted, k)
    end
    for _,k in ipairs(sorted) do
        Print('local %-30s = ht.locals["%s"]["%s"]', k, key, k)
    end
end
