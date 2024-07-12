---------//-- LuaFormatter on
bestiaryControllerCyclopedia = Controller:new()

function bestiaryControllerCyclopedia:onInit()
    bestiaryControllerCyclopedia:registerEvents(g_game, {
        onParseBestiaryGroups = onParseBestiaryGroups,
        onParseBestiaryOverview = onParseBestiaryOverview,
        onParseBestiaryMonster = onParseBestiaryMonster

    })

end

function bestiaryControllerCyclopedia:onGameStart()

end

function bestiaryControllerCyclopedia:onGameEnd()

end

function bestiaryControllerCyclopedia:onTerminate()

end

function showBestiary()

    bestiaryPanel = g_ui.loadUI("bestiary", contentContainer)
    bestiaryPanel:show()
    exportWidgetDataToJson(bestiaryPanel, "bestiaryPanel.json")

end

--[[ 
Send = 	
    g_game.requestBestiaryOverview(Category) // array
    g_game.requestBestiarySearch(creatures)
    g_game.requestBestiaryMonster(widget:getId())
    g_game.requestBestiary()

Get:

    onParseBestiaryGroups
        array = {
            name
            amount
            know
        }


    onParseBestiaryOverview(name, creatures)
            name [string] = "result" else
            creatures [array] ={
                    id
                    currentLevel
            }


    onParseBestiaryMonster
            name
            ocorrence
            difficulty
            raceId
            killCounter
            thirdDifficulty
            killCounter
            currentLevel

            maxHealth
            experience
            speed
            armor
            mitigation .. "%"
            charmValue

            combat {
                value
                margin
                color
                tooltip
            }


            loot = {
                name
                itemId
                type
                diffculty
                stackable
                location
            }
]]

