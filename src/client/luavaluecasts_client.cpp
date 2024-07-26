/*
 * Copyright (c) 2010-2022 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include "luavaluecasts_client.h"
#include <framework/luaengine/luainterface.h>

int push_luavalue(const Outfit& outfit)
{
    g_lua.createTable(0, 8);
    g_lua.pushInteger(outfit.getId());
    g_lua.setField("type");
    g_lua.pushInteger(outfit.getAuxId());
    g_lua.setField("auxType");
    if (g_game.getFeature(Otc::GamePlayerAddons)) {
        g_lua.pushInteger(outfit.getAddons());
        g_lua.setField("addons");
    }
    g_lua.pushInteger(outfit.getHead());
    g_lua.setField("head");
    g_lua.pushInteger(outfit.getBody());
    g_lua.setField("body");
    g_lua.pushInteger(outfit.getLegs());
    g_lua.setField("legs");
    g_lua.pushInteger(outfit.getFeet());
    g_lua.setField("feet");
    if (g_game.getFeature(Otc::GamePlayerMounts)) {
        g_lua.pushInteger(outfit.getMount());
        g_lua.setField("mount");
    }
    return 1;
}

bool luavalue_cast(int index, Outfit& outfit)
{
    if (!g_lua.isTable(index))
        return false;

    g_lua.getField("type", index);
    outfit.setId(g_lua.popInteger());
    g_lua.getField("auxType", index);
    outfit.setAuxId(g_lua.popInteger());
    if (g_game.getFeature(Otc::GamePlayerAddons)) {
        g_lua.getField("addons", index);
        outfit.setAddons(g_lua.popInteger());
    }
    g_lua.getField("head", index);
    outfit.setHead(g_lua.popInteger());
    g_lua.getField("body", index);
    outfit.setBody(g_lua.popInteger());
    g_lua.getField("legs", index);
    outfit.setLegs(g_lua.popInteger());
    g_lua.getField("feet", index);
    outfit.setFeet(g_lua.popInteger());
    if (g_game.getFeature(Otc::GamePlayerMounts)) {
        g_lua.getField("mount", index);
        outfit.setMount(g_lua.popInteger());
    }
    if (g_game.getFeature(Otc::GameWingsAurasEffectsShader)) {
        g_lua.getField("wings", index);
        outfit.setWing(g_lua.popInteger());
        g_lua.getField("effects", index);
        outfit.setEffect(g_lua.popInteger());
        g_lua.getField("auras", index);
        outfit.setAura(g_lua.popInteger());
        g_lua.getField("shaders", index);
        outfit.setShader(g_lua.popString());

    }

    return true;
}

int push_luavalue(const Position& pos)
{
    if (pos.isValid()) {
        g_lua.createTable(0, 3);
        g_lua.pushInteger(pos.x);
        g_lua.setField("x");
        g_lua.pushInteger(pos.y);
        g_lua.setField("y");
        g_lua.pushInteger(pos.z);
        g_lua.setField("z");
    } else
        g_lua.pushNil();

    return 1;
}

bool luavalue_cast(int index, Position& pos)
{
    if (!g_lua.isTable(index))
        return false;

    g_lua.getField("x", index);
    pos.x = g_lua.popInteger();
    g_lua.getField("y", index);
    pos.y = g_lua.popInteger();
    g_lua.getField("z", index);
    pos.z = g_lua.popInteger();

    return true;
}

int push_luavalue(const MarketData& data)
{
    g_lua.createTable(0, 6);
    g_lua.pushInteger(data.category);
    g_lua.setField("category");
    g_lua.pushString(data.name);
    g_lua.setField("name");
    g_lua.pushInteger(data.requiredLevel);
    g_lua.setField("requiredLevel");
    g_lua.pushInteger(data.restrictVocation);
    g_lua.setField("restrictVocation");
    g_lua.pushInteger(data.showAs);
    g_lua.setField("showAs");
    g_lua.pushInteger(data.tradeAs);
    g_lua.setField("tradeAs");

    return 1;
}

bool luavalue_cast(int index, MarketData& data)
{
    if (!g_lua.isTable(index))
        return false;

    g_lua.getField("category", index);
    data.category = static_cast<ITEM_CATEGORY>(g_lua.popInteger());
    g_lua.getField("name", index);
    data.name = g_lua.popString();
    g_lua.getField("requiredLevel", index);
    data.requiredLevel = g_lua.popInteger();
    g_lua.getField("restrictVocation", index);
    data.restrictVocation = g_lua.popInteger();
    g_lua.getField("showAs", index);
    data.showAs = g_lua.popInteger();
    g_lua.getField("tradeAs", index);
    data.tradeAs = g_lua.popInteger();

    return true;
}

int push_luavalue(const Light& light)
{
    g_lua.createTable(0, 2);
    g_lua.pushInteger(light.color);
    g_lua.setField("color");
    g_lua.pushInteger(light.intensity);
    g_lua.setField("intensity");

    return 1;
}

bool luavalue_cast(int index, Light& light)
{
    if (!g_lua.isTable(index))
        return false;

    g_lua.getField("color", index);
    light.color = g_lua.popInteger();
    g_lua.getField("intensity", index);
    light.intensity = g_lua.popInteger();

    return true;
}

int push_luavalue(const UnjustifiedPoints& unjustifiedPoints)
{
    g_lua.createTable(0, 7);
    g_lua.pushInteger(unjustifiedPoints.killsDay);
    g_lua.setField("killsDay");
    g_lua.pushInteger(unjustifiedPoints.killsDayRemaining);
    g_lua.setField("killsDayRemaining");
    g_lua.pushInteger(unjustifiedPoints.killsWeek);
    g_lua.setField("killsWeek");
    g_lua.pushInteger(unjustifiedPoints.killsWeekRemaining);
    g_lua.setField("killsWeekRemaining");
    g_lua.pushInteger(unjustifiedPoints.killsMonth);
    g_lua.setField("killsMonth");
    g_lua.pushInteger(unjustifiedPoints.killsMonthRemaining);
    g_lua.setField("killsMonthRemaining");
    g_lua.pushInteger(unjustifiedPoints.skullTime);
    g_lua.setField("skullTime");

    return 1;
}

bool luavalue_cast(int index, UnjustifiedPoints& unjustifiedPoints)
{
    if (!g_lua.isTable(index))
        return false;

    g_lua.getField("killsDay", index);
    unjustifiedPoints.killsDay = g_lua.popInteger();
    g_lua.getField("killsDayRemaining", index);
    unjustifiedPoints.killsDayRemaining = g_lua.popInteger();
    g_lua.getField("killsWeek", index);
    unjustifiedPoints.killsWeek = g_lua.popInteger();
    g_lua.getField("killsWeekRemaining", index);
    unjustifiedPoints.killsWeekRemaining = g_lua.popInteger();
    g_lua.getField("killsMonth", index);
    unjustifiedPoints.killsMonth = g_lua.popInteger();
    g_lua.getField("killsMonthRemaining", index);
    unjustifiedPoints.killsMonthRemaining = g_lua.popInteger();
    g_lua.getField("skullTime", index);
    unjustifiedPoints.skullTime = g_lua.popInteger();
    return true;
}

int push_luavalue(const Imbuement& i)
{
    g_lua.createTable(0, 11);
    g_lua.pushInteger(i.id);
    g_lua.setField("id");
    g_lua.pushString(i.name);
    g_lua.setField("name");
    g_lua.pushString(i.description);
    g_lua.setField("description");
    g_lua.pushString(i.group);
    g_lua.setField("group");
    g_lua.pushInteger(i.imageId);
    g_lua.setField("imageId");
    g_lua.pushInteger(i.duration);
    g_lua.setField("duration");
    g_lua.pushBoolean(i.premiumOnly);
    g_lua.setField("premiumOnly");
    g_lua.createTable(i.sources.size(), 0);
    for (size_t j = 0; j < i.sources.size(); ++j) {
        g_lua.createTable(0, 2);
        g_lua.pushObject(i.sources[j].first);
        g_lua.setField("item");
        g_lua.pushString(i.sources[j].second);
        g_lua.setField("description");
        g_lua.rawSeti(j + 1);
    }
    g_lua.setField("sources");
    g_lua.pushInteger(i.cost);
    g_lua.setField("cost");
    g_lua.pushInteger(i.successRate);
    g_lua.setField("successRate");
    g_lua.pushInteger(i.protectionCost);
    g_lua.setField("protectionCost");
    return 1;
}

int push_luavalue(const ImbuementTrackerItem& i)
{
    g_lua.createTable(0, 3);
    g_lua.pushInteger(i.slot);
    g_lua.setField("slot");
    g_lua.pushObject(i.item);
    g_lua.setField("item");
    g_lua.createTable(i.slots.size(), 0);
    for (auto& [id, slot] : i.slots) {
        g_lua.createTable(0, 5);
        g_lua.pushInteger(id);
        g_lua.setField("id");
        g_lua.pushString(slot.name);
        g_lua.setField("name");
        g_lua.pushInteger(slot.iconId);
        g_lua.setField("iconId");
        g_lua.pushInteger(slot.duration);
        g_lua.setField("duration");
        g_lua.pushBoolean(slot.state);
        g_lua.setField("state");
        g_lua.rawSeti(id + 1);
    }
    g_lua.setField("slots");
    return 1;
}

int push_luavalue(const CyclopediaBestiaryRace& race) {
    g_lua.createTable(0, 4);
    g_lua.pushInteger(race.race);
    g_lua.setField("race");
    g_lua.pushString(race.bestClass);
    g_lua.setField("bestClass");
    g_lua.pushInteger(race.count);
    g_lua.setField("count");
    g_lua.pushInteger(race.unlockedCount);
    g_lua.setField("unlockedCount");
    return 1;
}

int push_luavalue(const LootItem& lootItem) {
    g_lua.createTable(0, 5);
    g_lua.pushInteger(lootItem.itemId);
    g_lua.setField("itemId");
    g_lua.pushInteger(lootItem.diffculty);
    g_lua.setField("diffculty");
    g_lua.pushInteger(lootItem.specialEvent);
    g_lua.setField("specialEvent");
    g_lua.pushString(lootItem.name);
    g_lua.setField("name");
    g_lua.pushInteger(lootItem.amount);
    g_lua.setField("amount");
    return 1;
}

int push_luavalue(const BestiaryMonsterData& data) {
    g_lua.createTable(0, 16);
    g_lua.pushInteger(data.id);
    g_lua.setField("id");
    g_lua.pushString(data.bestClass);
    g_lua.setField("class");
    g_lua.pushInteger(data.currentLevel);
    g_lua.setField("currentLevel");
    g_lua.pushInteger(data.killCounter);
    g_lua.setField("killCounter");
    g_lua.pushInteger(data.thirdDifficulty);
    g_lua.setField("thirdDifficulty");
    g_lua.pushInteger(data.secondUnlock);
    g_lua.setField("secondUnlock");
    g_lua.pushInteger(data.lastProgressKillCount);
    g_lua.setField("lastProgressKillCount");
    g_lua.pushInteger(data.difficulty);
    g_lua.setField("difficulty");
    g_lua.pushInteger(data.ocorrence);
    g_lua.setField("ocorrence");

    g_lua.createTable(data.loot.size(), 0);
    for (size_t i = 0; i < data.loot.size(); ++i) {
        push_luavalue(data.loot[i]);
        g_lua.rawSeti(i + 1);
    }
    g_lua.setField("loot");

    if (data.currentLevel > 1) {
        g_lua.pushInteger(data.charmValue);
        g_lua.setField("charmValue");
        g_lua.pushInteger(data.attackMode);
        g_lua.setField("attackMode");
        g_lua.pushInteger(data.maxHealth);
        g_lua.setField("maxHealth");
        g_lua.pushInteger(data.experience);
        g_lua.setField("experience");
        g_lua.pushInteger(data.speed);
        g_lua.setField("speed");
        g_lua.pushInteger(data.armor);
        g_lua.setField("armor");
        g_lua.pushNumber(data.mitigation);
        g_lua.setField("mitigation");
    }

    if (data.currentLevel > 2) {
        g_lua.createTable(data.combat.size(), 0);
        for (const auto& [elementId, elementValue] : data.combat) {
            g_lua.pushInteger(elementValue);
            g_lua.rawSeti(elementId + 1);
        }
        g_lua.setField("combat");
        g_lua.pushString(data.location);
        g_lua.setField("location");
    }

    return 1;
}

int push_luavalue(const CharmData& charm) {
    g_lua.createTable(0, 7);
    g_lua.pushInteger(charm.id);
    g_lua.setField("id");
    g_lua.pushString(charm.name);
    g_lua.setField("name");
    g_lua.pushString(charm.description);
    g_lua.setField("description");
    g_lua.pushInteger(charm.unlockPrice);
    g_lua.setField("unlockPrice");
    g_lua.pushInteger(charm.activated);
    g_lua.setField("activated");
    g_lua.pushBoolean(charm.asignedStatus);
    g_lua.setField("asignedStatus");
    g_lua.pushInteger(charm.raceId);
    g_lua.setField("raceId");
    g_lua.pushInteger(charm.removeRuneCost);
    g_lua.setField("removeRuneCost");
    return 1;
}

int push_luavalue(const BestiaryCharmsData& charmData) {
    g_lua.createTable(0, 3);
    g_lua.pushInteger(charmData.points);
    g_lua.setField("points");

    g_lua.createTable(charmData.charms.size(), 0);
    for (size_t i = 0; i < charmData.charms.size(); ++i) {
        push_luavalue(charmData.charms[i]);
        g_lua.rawSeti(i + 1);
    }
    g_lua.setField("charms");

    g_lua.createTable(charmData.finishedMonsters.size(), 0);
    for (size_t i = 0; i < charmData.finishedMonsters.size(); ++i) {
        g_lua.pushInteger(charmData.finishedMonsters[i]);
        g_lua.rawSeti(i + 1);
    }
    g_lua.setField("finishedMonsters");

    return 1;
}

int push_luavalue(const BestiaryOverviewMonsters& monster) {
    g_lua.createTable(0, 3);
    g_lua.pushInteger(monster.id);
    g_lua.setField("id");
    g_lua.pushInteger(monster.currentLevel);
    g_lua.setField("currentLevel");
    g_lua.pushInteger(monster.occurrence);
    g_lua.setField("occurrence");
    return 1;
}

int push_luavalue(const CyclopediaCharacterGeneralStats& stats) {
    g_lua.createTable(0, 26);
    g_lua.pushInteger(stats.experience);
    g_lua.setField("xperiencee");
    g_lua.pushInteger(stats.level);
    g_lua.setField("level");
    g_lua.pushInteger(stats.levelPercent);
    g_lua.setField("levelPercent");
    g_lua.pushInteger(stats.baseExpGain);
    g_lua.setField("baseExpGain");
    g_lua.pushInteger(stats.lowLevelExpBonus);
    g_lua.setField("lowLevelExpBonus");
    g_lua.pushInteger(stats.XpBoostPercent);
    g_lua.setField("XpBoostPercent");
    g_lua.pushInteger(stats.staminaExpBonus);
    g_lua.setField("staminaExpBonus");
    g_lua.pushInteger(stats.XpBoostBonusRemainingTime);
    g_lua.setField("XpBoostBonusRemainingTime");
    g_lua.pushInteger(stats.canBuyXpBoost);
    g_lua.setField("canBuyXpBoost");
    g_lua.pushInteger(stats.health);
    g_lua.setField("health");
    g_lua.pushInteger(stats.maxHealth);
    g_lua.setField("maxHealth");
    g_lua.pushInteger(stats.mana);
    g_lua.setField("mana");
    g_lua.pushInteger(stats.maxMana);
    g_lua.setField("maxMana");
    g_lua.pushInteger(stats.soul);
    g_lua.setField("soul");
    g_lua.pushInteger(stats.staminaMinutes);
    g_lua.setField("staminaMinutes");
    g_lua.pushInteger(stats.regenerationCondition);
    g_lua.setField("regenerationCondition");
    g_lua.pushInteger(stats.offlineTrainingTime);
    g_lua.setField("offlineTrainingTime");
    g_lua.pushInteger(stats.speed);
    g_lua.setField("speed");
    g_lua.pushInteger(stats.baseSpeed);
    g_lua.setField("baseSpeed");
    g_lua.pushInteger(stats.capacity);
    g_lua.setField("capacity");
    g_lua.pushInteger(stats.baseCapacity);
    g_lua.setField("baseCapacity");
    g_lua.pushInteger(stats.freeCapacity);
    g_lua.setField("freeCapacity");
    g_lua.pushInteger(stats.magicLevel);
    g_lua.setField("magicLevel");
    g_lua.pushInteger(stats.baseMagicLevel);
    g_lua.setField("baseMagicLevel");
    g_lua.pushInteger(stats.loyaltyMagicLevel);
    g_lua.setField("loyaltyMagicLevel");
    g_lua.pushInteger(stats.magicLevelPercent);
    g_lua.setField("magicLevelPercent");

    return 1;
}

bool luavalue_cast(int index, CyclopediaCharacterGeneralStats& stats)
{
    if (!g_lua.isTable(index))
        return false;

    g_lua.getField("experience", index);
    stats.experience = g_lua.popInteger();
    g_lua.getField("level", index);
    stats.level = g_lua.popInteger();
    g_lua.getField("levelPercent", index);
    stats.levelPercent = g_lua.popInteger();
    g_lua.getField("baseExpGain", index);
    stats.baseExpGain = g_lua.popInteger();
    g_lua.getField("lowLevelExpBonus", index);
    stats.lowLevelExpBonus = g_lua.popInteger();
    g_lua.getField("XpBoostPercent", index);
    stats.XpBoostPercent = g_lua.popInteger();
    g_lua.getField("staminaExpBonus", index);
    stats.staminaExpBonus = g_lua.popInteger();
    g_lua.getField("XpBoostBonusRemainingTime", index);
    stats.XpBoostBonusRemainingTime = g_lua.popInteger();
    g_lua.getField("canBuyXpBoost", index);
    stats.canBuyXpBoost = g_lua.popInteger();
    g_lua.getField("health", index);
    stats.health = g_lua.popInteger();
    g_lua.getField("maxHealth", index);
    stats.maxHealth = g_lua.popInteger();
    g_lua.getField("mana", index);
    stats.mana = g_lua.popInteger();
    g_lua.getField("maxMana", index);
    stats.maxMana = g_lua.popInteger();
    g_lua.getField("soul", index);
    stats.soul = g_lua.popInteger();
    g_lua.getField("staminaMinutes", index);
    stats.staminaMinutes = g_lua.popInteger();
    g_lua.getField("regenerationCondition", index);
    stats.regenerationCondition = g_lua.popInteger();
    g_lua.getField("offlineTrainingTime", index);
    stats.offlineTrainingTime = g_lua.popInteger();
    g_lua.getField("speed", index);
    stats.speed = g_lua.popInteger();
    g_lua.getField("baseSpeed", index);
    stats.baseSpeed = g_lua.popInteger();
    g_lua.getField("capacity", index);
    stats.capacity = g_lua.popInteger();
    g_lua.getField("baseCapacity", index);
    stats.baseCapacity = g_lua.popInteger();
    g_lua.getField("freeCapacity", index);
    stats.freeCapacity = g_lua.popInteger();
    g_lua.getField("magicLevel", index);
    stats.magicLevel = g_lua.popInteger();
    g_lua.getField("baseMagicLevel", index);
    stats.baseMagicLevel = g_lua.popInteger();
    g_lua.getField("loyaltyMagicLevel", index);
    stats.loyaltyMagicLevel = g_lua.popInteger();
    g_lua.getField("magicLevelPercent", index);
    stats.magicLevelPercent = g_lua.popInteger();

    return true;
}

int push_luavalue(const CyclopediaCharacterCombatStats& data) {
    g_lua.createTable(0, 7);
    g_lua.pushInteger(data.weaponElement);
    g_lua.setField("weaponElement");
    g_lua.pushInteger(data.weaponMaxHitChance);
    g_lua.setField("weaponMaxHitChance");
    g_lua.pushInteger(data.weaponElementDamage);
    g_lua.setField("weaponElementDamage");
    g_lua.pushInteger(data.weaponElementType);
    g_lua.setField("weaponElementType");
    g_lua.pushInteger(data.defense);
    g_lua.setField("defense");
    g_lua.pushInteger(data.armor);
    g_lua.setField("armor");
    g_lua.pushInteger(data.haveBlessings);
    g_lua.setField("haveBlessings");
    return 1;
}

int push_luavalue(const BosstiaryData& boss) {
    g_lua.createTable(0, 4);
    g_lua.pushInteger(boss.raceId);
    g_lua.setField("raceId");
    g_lua.pushInteger(boss.category);
    g_lua.setField("category");
    g_lua.pushInteger(boss.kills);
    g_lua.setField("kills");
    g_lua.pushInteger(boss.isTrackerActived);
    g_lua.setField("isTrackerActived");
    return 1;
}

int push_luavalue(const BosstiarySlot& slot) {
    g_lua.createTable(0, 7);
    g_lua.pushInteger(slot.bossRace);
    g_lua.setField("bossRace");
    g_lua.pushInteger(slot.killCount);
    g_lua.setField("killCount");
    g_lua.pushInteger(slot.lootBonus);
    g_lua.setField("lootBonus");
    g_lua.pushInteger(slot.killBonus);
    g_lua.setField("killBonus");
    g_lua.pushInteger(slot.bossRaceRepeat);
    g_lua.setField("bossRaceRepeat");
    g_lua.pushInteger(slot.removePrice);
    g_lua.setField("removePrice");
    g_lua.pushInteger(slot.inactive);
    g_lua.setField("inactive");
    return 1;
}

// Función para convertir BossUnlocked a valor Lua
int push_luavalue(const BossUnlocked& boss) {
    g_lua.createTable(0, 2);
    g_lua.pushInteger(boss.bossId);
    g_lua.setField("bossId");
    g_lua.pushInteger(boss.bossRace);
    g_lua.setField("bossRace");
    return 1;
}

// Función para convertir BosstiarySlotsData a valor Lua
int push_luavalue(const BosstiarySlotsData& data) {
    g_lua.createTable(0, 13);
    g_lua.pushInteger(data.playerPoints);
    g_lua.setField("playerPoints");
    g_lua.pushInteger(data.totalPointsNextBonus);
    g_lua.setField("totalPointsNextBonus");
    g_lua.pushInteger(data.currentBonus);
    g_lua.setField("currentBonus");
    g_lua.pushInteger(data.nextBonus);
    g_lua.setField("nextBonus");

    g_lua.pushBoolean(data.isSlotOneUnlocked);
    g_lua.setField("isSlotOneUnlocked");
    g_lua.pushInteger(data.bossIdSlotOne);
    g_lua.setField("bossIdSlotOne");
    if (data.slotOneData) {
        push_luavalue(*data.slotOneData);
        g_lua.setField("slotOneData");
    }

    g_lua.pushBoolean(data.isSlotTwoUnlocked);
    g_lua.setField("isSlotTwoUnlocked");
    g_lua.pushInteger(data.bossIdSlotTwo);
    g_lua.setField("bossIdSlotTwo");
    if (data.slotTwoData) {
        push_luavalue(*data.slotTwoData);
        g_lua.setField("slotTwoData");
    }

    g_lua.pushBoolean(data.isTodaySlotUnlocked);
    g_lua.setField("isTodaySlotUnlocked");
    g_lua.pushInteger(data.boostedBossId);
    g_lua.setField("boostedBossId");
    if (data.todaySlotData) {
        push_luavalue(*data.todaySlotData);
        g_lua.setField("todaySlotData");
    }

    g_lua.pushBoolean(data.bossesUnlocked);
    g_lua.setField("bossesUnlocked");

    g_lua.createTable(data.bossesUnlockedData.size(), 0);
    for (size_t i = 0; i < data.bossesUnlockedData.size(); ++i) {
        push_luavalue(data.bossesUnlockedData[i]);
        g_lua.rawSeti(i + 1);
    }
    g_lua.setField("bossesUnlockedData");

    return 1;
}
