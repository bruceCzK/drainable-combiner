ISCombineAllContextMenu = {};

function ISCombineAllContextMenu.DoContextMenu(player, context, items)
    local contextItem = items[1]
    local combineableItems = {}
    combineableItems = getCombineableItems(items)

    if canCombineAll(combineableItems, player) then
        context:addOption(getText("UI_ContextMenu_CombineAll"), combineableItems, ISCombineAllContextMenu.onCombineAll,
            player)
    end
end

function ISCombineAllContextMenu.onCombineAll(items, player, isChecked, toReturn)
    local character = getSpecificPlayer(player)
    local inventory = character:getInventory()
    local combineableItems = {}
    local types = {}
    combineableItems, types = categorizeCombineable(items)
    local itemsToReturnToContainer = (toReturn ~= nil and #toReturn > 0) and toReturn or {}
    local isChecked = isChecked ~= nil and isChecked or false -- check for where combine is happening from (inventory or other container)

    local typeToCombine = types[1]
    if typeToCombine ~= nil then
        if isChecked == false then -- only setup transfer once
            if inventory ~= combineableItems[types[1]][1]:getContainer() then
                if itemsToReturnToContainer == nil or #itemsToReturnToContainer == 0 then
                    for _, v in pairs(items) do
                        if hasCombineableDelta(v) then
                            transferTo(character, v, v:getContainer(), inventory)
                            table.insert(itemsToReturnToContainer, {
                                container = v:getContainer(),
                                item = v
                            })
                        end
                    end
                end
            end

            isChecked = true
        end -- end initial transfer

        combineItems(combineableItems[typeToCombine], items, player, isChecked, itemsToReturnToContainer)
    else -- transfer items back to original container after combine all
        for _, v in pairs(itemsToReturnToContainer) do
            if inventory:contains(v.item) then
                transferTo(character, v.item, inventory, v.container)
            end
        end
    end
end

function combineItems(combineable, all, player, isOutsideInventory, itemsToReturnToContainer)
    local firstItem = combineable[1]
    local lastItem = combineable[#combineable]

    if firstItem ~= lastItem then
        local action = ISCombineAll:new(player, firstItem, lastItem, 90)
        action:setOnComplete(ISCombineAllContextMenu.onCombineAll, all, player, isOutsideInventory,
            itemsToReturnToContainer)
        ISTimedActionQueue.add(action)
    end
end

function canCombineAll(items, player)
    local combineable = {}
    local types = {}
    combineable, types = categorizeCombineable(items)

    if #types == 0 then
        return false
    end

    for _, type in pairs(combineable) do
        local totalCombineable = 0

        for _, item in pairs(type) do
            if not instanceof(item, "DrainableComboItem") or item:canConsolidate() ~= true then
                return false
            end

            if hasCombineableDelta(item) then 
                totalCombineable = totalCombineable + 1
            end
        end

        if type[1] == type[2] and hasCombineableDelta(type[1]) then -- if collapsed, account for ghost row
            totalCombineable = totalCombineable - 1
        end

        if totalCombineable <= 1 then
            return false
        end
    end
    return true
end

function hasCombineableDelta(item)
    local delta = item:getDelta()
    return delta < 1.0 and delta > 0.0
end

function categorizeCombineable(items, existingCombineable)
    local combineable = existingCombineable ~= nil and existingCombineable or {}
    local types = {}

    for _, v in pairs(items) do
        if hasCombineableDelta(v) then
            if v:getName() == "Water Bottle" or v:getName() == "Water Bottle (Tainted)" then
                insertOrAddToTable(combineable, v, v:getName())
            else
                insertOrAddToTable(combineable, v, v:getType())
            end
        end
    end

    for _, v in pairs(combineable) do
        if #v > 1 then
            local type = (v[1]:getName() == "Water Bottle" or v[1]:getName() == "Water Bottle (Tainted)") and v[1]:getName() or v[1]:getType()
            table.insert(types, type)
        end
    end

    return combineable, types
end

function insertOrAddToTable(combineable, item, loc)
    if combineable[loc] ~= nil then
        table.insert(combineable[loc], item)
    else
        combineable[loc] = {item}
    end
end

function transferTo(character, item, sourceContainer, destinationContainer)
    local action = ISInventoryTransferAction:new(character, item, sourceContainer, destinationContainer)
    ISTimedActionQueue.add(action)
end

function getCombineableItems(items, existingCombineableItems)
    local comebineableItems = existingCombineableItems ~= nil and existingCombineableItems or {}

    for _, v in pairs(items) do
        if instanceof(v, "DrainableComboItem") then -- if expanded
            table.insert(comebineableItems, v)
        elseif type(v) == "table" then -- if collapsed
            local tableItems = v.items
            getCombineableItems(tableItems, comebineableItems)
        end
    end

    return comebineableItems
end

Events.OnFillInventoryObjectContextMenu.Add(ISCombineAllContextMenu.DoContextMenu);
