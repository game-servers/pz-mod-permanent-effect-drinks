--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

PermanentRecipes = {
    -- TODO: Add possibility to create custom recipes in server side Lua directory.
    Recipes = {
        Vanilla = {
            ["MakeWhiskey"] = {
                name = "MakeWhiskey",
                type = "Vanilla",
                disabled = false,
                sound = "PourWaterIntoObject",
                texture = "Item_WhiskeyFull",
                time = 300,
                cookingSkill = 3,
                usedItems = {
                    ["Base.WhiskeyWaterFull"] = 1,
                    ["Base.Yeast"] = 1,
                    ["Base.Corn"] = 1,
                    ["Base.UnusableWood"] = 1,
                },
                result = "Base.WhiskeyFull",
                additionalResults = {},
            },
            ["MakeWine"] = {
                name = "MakeWine",
                type = "Vanilla",
                disabled = false,
                sound = "PourWaterIntoObject",
                texture = "Item_Wine2Full",
                time = 300,
                cookingSkill = 3,
                usedItems = {
                    ["Base.WineWaterFull"] = 1,
                    ["Base.Sugar"] = 1,
                    ["Base.Grapes"] = 1,
                },
                result = "Base.Wine2",
                additionalResults = {},
            },
            ["MakeBeer"] = {
                name = "MakeBeer",
                type = "Vanilla",
                disabled = false,
                sound = "PourWaterIntoObject",
                texture = "Item_BeerBottle",
                time = 300,
                cookingSkill = 3,
                usedItems = {
                    ["Base.BeerWaterFull"] = 1,
                    ["Base.Sugar"] = 1,
                    ["Base.Corn"] = 1,
                },
                result = "Base.BeerBottle",
                additionalResults = {},
            },
        },

        Exclusive = {
            ["MakeSlenderDoe"] = {
                name = "MakeSlenderDoe",
                type = "Exclusive",
                disabled = false,
                sound = "PourWaterIntoObject",
                texture = "media/textures/Item_SlenderDoe.png",
                time = 300,
                cookingSkill = 10,
                usedItems = {
                    ["Permanent.ExclusiveRecipe"] = 1,
                    ["Base.Wine2"] = 1,
                    ["Base.Wine"] = 1,
                    ["Base.GrapeLeaves"] = 4,
                    ["Base.Milk"] = 1,
                    ["Base.Pickles"] = 1,
                },
                result = "Permanent.SlenderDoe",
                additionalResults = {},
            },
            ["MakeNicotineOverdose"] = {
                name = "MakeNicotineOverdose",
                type = "Exclusive",
                disabled = false,
                sound = "PourWaterIntoObject",
                texture = "media/textures/Item_NicotineOverdose.png",
                time = 300,
                cookingSkill = 10,
                usedItems = {
                    ["Permanent.ExclusiveRecipe"] = 1,
                    ["Base.WhiskeyFull"] = 1,
                    ["Base.Sugar"] = 1,
                    ["Base.Cigarettes"] = 1000,
                    ["Base.Coffee2"] = 5,
                },
                result = "Permanent.NicotineOverdose",
                additionalResults = {},
            },
        },
    },
}

PermanentRecipes.IsEnoughMaterials = function(character, recipe)
    if not recipe then return false end

    local inventory = character:getInventory()

    for itemCode, neededItemsCount in pairs(recipe.usedItems) do
        local items = inventory:getAllType(itemCode)

        if not items or items:size() < neededItemsCount then
            return false
        end

        local inventoryItemsCount = 0

        for i=1, items:size() do
            local itemToRemove = items:get(i-1)

            if not PermanentRecipes.IsItemBlocked(character, itemToRemove) then
                if inventoryItemsCount >= neededItemsCount then
                    break
                end

                inventoryItemsCount = inventoryItemsCount + 1
            end
        end

        if inventoryItemsCount ~= neededItemsCount then
            return false
        end
    end

    return true
end

PermanentRecipes.IsItemBlocked = function(character, item)
    if item:isBroken() then
        return true
    end

    if item:isFavorite() then
        return true
    end

    if item:isEquipped() then
        return true
    end

    return character:isEquipped(item) or character:isAttachedItem(item)
end
