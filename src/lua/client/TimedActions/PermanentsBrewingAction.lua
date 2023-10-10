--
-- Copyright (c) 2023 outdead.
-- Use of this source code is governed by the MIT license
-- that can be found in the LICENSE file.
--

require "TimedActions/ISBaseTimedAction"
require 'PermanentRecipes'

PermanentsBrewingAction = ISBaseTimedAction:derive("PermanentsBrewingAction");

function PermanentsBrewingAction:isValid()
    if not PermanentRecipes.IsEnoughMaterials(self.character, self.recipe) then
        return false
    end

    return true
end

function PermanentsBrewingAction:waitToStart()
    return false
end

function PermanentsBrewingAction:update()
end

function PermanentsBrewingAction:start()
    local inventory = self.character:getInventory()

    --local animation = PermanentRecipes.GetAnimation(self.recipe.animationType)
    --self:setActionAnim(animation);

    self.sound = self.character:playSound(self.recipe.sound)
end

function PermanentsBrewingAction:stop()
    ISBaseTimedAction.stop(self);
end

function PermanentsBrewingAction:perform()
    local inventory = self.character:getInventory()

    for itemCode, neededItemsCount in pairs(self.recipe.usedItems) do
        local items = inventory:getAllType(itemCode)

        if items:size() < neededItemsCount then
            return self:performNext()
        end

        local removedItemsCount = 0

        for i=1, items:size() do
            local itemToRemove = items:get(i-1)

            if not PermanentRecipes.IsItemBlocked(self.character, itemToRemove) then
                if removedItemsCount >= neededItemsCount then
                    break
                end

                if itemToRemove:getContainer() then
                    itemToRemove:getContainer():Remove(itemToRemove)
                else
                    inventory:Remove(itemToRemove)
                end

                removedItemsCount = removedItemsCount + 1
            end
        end

        if removedItemsCount ~= neededItemsCount then
            return self:performNext()
        end
    end

    -- Add results to player inventory.
    inventory:AddItems(self.recipe.result, 1)
    for itemCode, addItemsCount in pairs(self.recipe.additionalResults) do
        inventory:AddItems(itemCode, addItemsCount)
    end

    return self:performNext()
end

function PermanentsBrewingAction:new(character, recipe, object)
    local cookingLevel = character:getPerkLevel(Perks.Cooking)

    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character;
    o.stopOnWalk = true;
    o.stopOnRun = true;
    o.maxTime = recipe.time - (cookingLevel * 20 - 100);
    -- custom fields
    o.object = object
    o.recipe = recipe
    return o
end

function PermanentsBrewingAction:performNext()
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end
