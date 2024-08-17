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

#pragma once

#include <bitset>
#include <framework/core/timer.h>
#include "animatedtext.h"
#include "container.h"
#include "creature.h"
#include "declarations.h"
#include "item.h"
#include "outfit.h"
#include "protocolgame.h"

struct UnjustifiedPoints
{
    bool operator==(const UnjustifiedPoints& other) const
    {
        return killsDay == other.killsDay &&
            killsDayRemaining == other.killsDayRemaining &&
            killsWeek == other.killsWeek &&
            killsWeekRemaining == other.killsWeekRemaining &&
            killsMonth == other.killsMonth &&
            killsMonthRemaining == other.killsMonthRemaining &&
            skullTime == other.skullTime;
    }
    uint8_t killsDay;
    uint8_t killsDayRemaining;
    uint8_t killsWeek;
    uint8_t killsWeekRemaining;
    uint8_t killsMonth;
    uint8_t killsMonthRemaining;
    uint8_t skullTime;
};

struct BlessData
{
    uint16_t blessBitwise;
    uint8_t playerBlessCount;
    uint8_t store;
};

struct LogData
{
    uint32_t timestamp;
    uint8_t colorMessage;
    std::string_view historyMessage;
};

struct BlessDialogData
{
    uint8_t totalBless;
    std::vector<BlessData> blesses;
    uint8_t premium;
    uint8_t promotion;
    uint8_t pvpMinXpLoss;
    uint8_t pvpMaxXpLoss;
    uint8_t pveExpLoss;
    uint8_t equipPvpLoss;
    uint8_t equipPveLoss;
    uint8_t skull;
    uint8_t aol;
    std::vector<LogData> logs;
};

using Vip = std::tuple<std::string, uint32_t, std::string, int, bool>;

struct StoreCategory
{
    std::string name;
    std::vector<StoreCategory> subCategories;
    uint8_t state;
    std::vector<std::string> icons;
    std::string parent;
};

struct SubOffer
{
    uint32_t id;
    uint16_t count;
    uint32_t price;
    uint8_t coinType;
    bool disabled;
    uint16_t disabledReason;
    uint8_t state;
    uint32_t validUntil;
    uint32_t basePrice;
};

struct StoreOffer
{
    std::string name;
    std::vector<SubOffer> subOffers;
    uint32_t ofertaid;
    std::string description;
    uint8_t type;
    std::string icon;
    uint16_t mountId;
    uint16_t itemId;
    uint16_t outfitId;
    uint8_t outfitHead, outfitBody, outfitLegs, outfitFeet;
    uint8_t sex;
    uint16_t maleOutfitId, femaleOutfitId;
    uint8_t tryOnType;
    uint16_t collection;
    uint16_t popularityScore;
    uint32_t stateNewUntil;
    bool configurable;
    uint16_t productsCapacity;
};

struct HomeOffer
{
    std::string name;
    uint8_t unknownByte;
    uint32_t id;
    uint16_t unknownU16;
    uint32_t price;
    uint8_t coinType;
    uint16_t disabledReasonIndex;
    uint8_t unknownByte2;
    uint8_t type;
    std::string icon;
    uint16_t mountClientId;
    uint16_t itemType;
    uint16_t sexId;
    struct { uint8_t lookHead, lookBody, lookLegs, lookFeet; } outfit;
    uint8_t tryOnType;
    uint16_t collection;
    uint16_t popularityScore;
    uint32_t stateNewUntil;
    uint8_t userConfiguration;
    uint16_t productsCapacity;
};

struct Banner
{
    std::string image;
    uint8_t bannerType;
    uint32_t offerId;
    uint8_t unknownByte1, unknownByte2;
};

struct StoreData
{
    std::string categoryName;
    uint32_t redirectId;
    std::vector<std::string> disableReasons;
    std::vector<HomeOffer> homeOffers;  
    std::vector<StoreOffer> storeOffers;
    std::vector<Banner> banners;
    uint8_t bannerDelay;
    bool tooManyResults;
};

struct CyclopediaCharacterGeneralStats
{
    uint64_t experience;
    uint16_t level;
    uint8_t levelPercent;
    uint16_t baseExpGain;
    uint16_t lowLevelExpBonus;
    uint16_t XpBoostPercent;
    uint16_t staminaExpBonus;
    uint16_t XpBoostBonusRemainingTime;
    uint8_t canBuyXpBoost;
    uint32_t health;
    uint32_t maxHealth;
    uint32_t mana;
    uint32_t maxMana;
    uint8_t soul;
    uint16_t staminaMinutes;
    uint16_t regenerationCondition;
    uint16_t offlineTrainingTime;
    uint16_t speed;
    uint16_t baseSpeed;
    uint32_t capacity;
    uint32_t baseCapacity;
    uint32_t freeCapacity;
    uint16_t magicLevel;
    uint16_t baseMagicLevel;
    uint16_t loyaltyMagicLevel;
    uint16_t magicLevelPercent;
};

struct CyclopediaCharacterCombatStats
{
    uint8_t weaponElement;
    uint16_t weaponMaxHitChance;
    uint8_t weaponElementDamage;
    uint8_t weaponElementType;
    uint16_t defense;
    uint16_t armor;
    uint8_t haveBlessings;
};

struct CyclopediaBestiaryRace
{
    uint8_t race;
    std::string bestClass;
    uint16_t count;
    uint16_t unlockedCount;
};

struct CharmData
{
    uint8_t id;
    std::string name;
    std::string description;
    uint16_t unlockPrice;
    bool unlocked;
    bool asignedStatus;
    uint16_t raceId;
    uint32_t removeRuneCost;
};

struct BestiaryCharmsData
{
    uint32_t points;
    std::vector<CharmData> charms;
    std::vector<uint16_t> finishedMonsters;
};

struct BestiaryOverviewMonsters
{
    uint16_t id;
    uint8_t currentLevel;
    uint8_t occurrence;
    uint16_t creatureAnimousBonus;
};

struct LootItem
{
    uint16_t itemId;
    uint8_t diffculty;
    uint8_t specialEvent;
    std::string name;
    uint8_t amount;
};

struct BestiaryMonsterData
{
    uint16_t id;
    std::string bestClass;
    uint8_t currentLevel;
    uint16_t AnimusMasteryBonus;
    uint16_t AnimusMasteryPoints;
    uint32_t killCounter;
    uint16_t thirdDifficulty;
    uint16_t secondUnlock;
    uint16_t lastProgressKillCount;
    uint8_t difficulty;
    uint8_t ocorrence;
    std::vector<LootItem> loot;
    uint16_t charmValue;
    uint8_t attackMode;
    uint32_t maxHealth;
    uint32_t experience;
    uint16_t speed;
    uint16_t armor;
    double mitigation;
    std::map<uint8_t, uint16_t> combat;
    std::string location;
};

struct BosstiaryData
{
    uint32_t raceId;
    uint8_t category;
    uint32_t kills;
    uint8_t isTrackerActived;
};

struct BosstiarySlot
{
    uint8_t bossRace;
    uint32_t killCount;
    uint16_t lootBonus;
    uint8_t killBonus;
    uint8_t bossRaceRepeat;
    uint32_t removePrice;
    uint8_t inactive;
};

struct BossUnlocked
{
    uint32_t bossId;
    uint8_t bossRace;
};

struct BosstiarySlotsData
{
    uint32_t playerPoints;
    uint32_t totalPointsNextBonus;
    uint16_t currentBonus;
    uint16_t nextBonus;
    bool isSlotOneUnlocked;
    uint32_t bossIdSlotOne;
    std::optional<BosstiarySlot> slotOneData;
    bool isSlotTwoUnlocked;
    uint32_t bossIdSlotTwo;
    std::optional<BosstiarySlot> slotTwoData;
    bool isTodaySlotUnlocked;
    uint32_t boostedBossId;
    std::optional<BosstiarySlot> todaySlotData;
    bool bossesUnlocked;
    std::vector<BossUnlocked> bossesUnlockedData;
};

struct ItemSummary
{
    uint16_t itemId;
    uint8_t classification;
    uint32_t amount;
};

struct CyclopediaCharacterItemSummary
{
    std::vector<ItemSummary> inventory;
    std::vector<ItemSummary> store;
    std::vector<ItemSummary> stash;
    std::vector<ItemSummary> depot;
    std::vector<ItemSummary> inbox;
};

struct RecentPvPKillEntry
{
    uint32_t timestamp;
    std::string description;
    uint8_t status;
};

struct CyclopediaCharacterRecentPvPKills
{
    std::vector<RecentPvPKillEntry> entries;
};

struct RecentDeathEntry
{
    uint32_t timestamp;
    std::string cause;
};

struct CyclopediaCharacterRecentDeaths
{
    std::vector<RecentDeathEntry> entries;
};

struct OutfitColorStruct
{
    uint8_t lookHead;
    uint8_t lookBody;
    uint8_t lookLegs;
    uint8_t lookFeet;
    uint8_t lookMountHead;
    uint8_t lookMountBody;
    uint8_t lookMountLegs;
    uint8_t lookMountFeet;
};

struct CharacterInfoOutfits
{
    uint16_t lookType;
    std::string name;
    uint8_t addons;
    uint8_t type;
    uint32_t isCurrent;
};

struct CharacterInfoMounts
{
    uint16_t mountId;
    std::string name;
    uint8_t type;
    uint32_t isCurrent;
};

struct CharacterInfoFamiliar
{
    uint16_t lookType;
    std::string name;
    uint8_t type;
    uint32_t isCurrent;
};

//@bindsingleton g_game
class Game
{
public:
    void init();
    void terminate();

private:
    void resetGameStates();

protected:
    void processConnectionError(const std::error_code& ec);
    void processDisconnect();
    void processPing();
    void processPingBack();

    static void processUpdateNeeded(const std::string_view signature);
    static void processLoginError(const std::string_view error);
    static void processLoginAdvice(const std::string_view message);
    static void processLoginWait(const std::string_view message, int time);
    static void processSessionEnd(int reason);
    static void processLogin();
    void processPendingGame();
    void processEnterGame();

    void processGameStart();
    void processGameEnd();
    void processDeath(int deathType, int penality);

    void processGMActions(const std::vector<uint8_t >& actions);
    void processInventoryChange(int slot, const ItemPtr& item);
    void processAttackCancel(uint32_t seq);
    void processWalkCancel(Otc::Direction direction);

    static void processPlayerHelpers(int helpers);
    void processPlayerModes(Otc::FightModes fightMode, Otc::ChaseModes chaseMode, bool safeMode, Otc::PVPModes pvpMode);

    // message related
    static void processTextMessage(Otc::MessageMode mode, const std::string_view text);
    static void processTalk(const std::string_view name, int level, Otc::MessageMode mode, const std::string_view text, int channelId, const Position& pos);

    // container related
    void processOpenContainer(int containerId, const ItemPtr& containerItem, const std::string_view name, int capacity, bool hasParent, const std::vector<ItemPtr>& items, bool isUnlocked, bool hasPages, int containerSize, int firstIndex);
    void processCloseContainer(int containerId);
    void processContainerAddItem(int containerId, const ItemPtr& item, int slot);
    void processContainerUpdateItem(int containerId, int slot, const ItemPtr& item);
    void processContainerRemoveItem(int containerId, int slot, const ItemPtr& lastItem);

    // channel related
    static void processChannelList(const std::vector<std::tuple<int, std::string> >& channelList);
    static void processOpenChannel(int channelId, const std::string_view name);
    static void processOpenPrivateChannel(const std::string_view name);
    static void processOpenOwnPrivateChannel(int channelId, const std::string_view name);
    static void processCloseChannel(int channelId);

    // rule violations
    static void processRuleViolationChannel(int channelId);
    static void processRuleViolationRemove(const std::string_view name);
    static void processRuleViolationCancel(const std::string_view name);
    static void processRuleViolationLock();

    // vip related
    void processVipAdd(uint32_t id, const std::string_view name, uint32_t status, const std::string_view description, int iconId, bool notifyLogin);
    void processVipStateChange(uint32_t id, uint32_t status);

    // tutorial hint
    static void processTutorialHint(int id);
    static void processAddAutomapFlag(const Position& pos, int icon, const std::string_view message);
    static void processRemoveAutomapFlag(const Position& pos, int icon, const std::string_view message);

    // outfit
    void processOpenOutfitWindow(const Outfit& currentOutfit, const std::vector<std::tuple<int, std::string, int> >& outfitList,
                                 const std::vector<std::tuple<int, std::string> >& mountList,
                                 const std::vector<std::tuple<int, std::string> >& wingsList,
                                 const std::vector<std::tuple<int, std::string> >& aurasList,
                                 const std::vector<std::tuple<int, std::string> >& effectsList,
                                 const std::vector<std::tuple<int, std::string>>& shaderList );

    // npc trade
    static void processOpenNpcTrade(const std::vector<std::tuple<ItemPtr, std::string, int, int, int> >& items);
    static void processPlayerGoods(int money, const std::vector<std::tuple<ItemPtr, int> >& goods);
    static void processCloseNpcTrade();

    // player trade
    static void processOwnTrade(const std::string_view name, const std::vector<ItemPtr>& items);
    static void processCounterTrade(const std::string_view name, const std::vector<ItemPtr>& items);
    static void processCloseTrade();

    // edit text/list
    static void processEditText(uint32_t id, int itemId, int maxLength, const std::string_view text, const std::string_view writer, const std::string_view date);
    static void processEditList(uint32_t id, int doorId, const std::string_view text);

    // questlog
    static void processQuestLog(const std::vector<std::tuple<int, std::string, bool> >& questList);
    static void processQuestLine(int questId, const std::vector<std::tuple<std::string, std::string> >& questMissions);

    // modal dialogs >= 970
    static void processModalDialog(uint32_t id, const std::string_view title, const std::string_view message, const std::vector<std::tuple<int, std::string> >
                                   & buttonList, int enterButton, int escapeButton, const std::vector<std::tuple<int, std::string> >
                                   & choiceList, bool priority);

    // cyclopedia
    static void processItemDetail(const ItemPtr& item, const std::vector<std::tuple<std::string, std::string>>& descriptions);
    static void processBestiaryRaces(const std::vector<CyclopediaBestiaryRace>& bestiaryRaces);
    static void processCyclopediaCharacterGeneralStats(const CyclopediaCharacterGeneralStats& stats, const std::vector<std::vector<uint16_t>>& skills, 
                                                    const std::vector<std::tuple<uint8_t, uint16_t>>& combats);
    static void processCyclopediaCharacterCombatStats(const CyclopediaCharacterCombatStats& data, const double mitigation, 
                                                    const std::vector<std::vector<uint16_t>>& additionalSkillsArray,
                                                    const std::vector<std::vector<uint16_t>>& forgeSkillsArray, const std::vector<uint16_t>& perfectShotDamageRangesArray,
                                                    const std::vector<std::tuple<uint8_t, uint16_t>>& combatsArray, 
                                                    const std::vector<std::tuple<uint16_t, uint16_t>>& concoctionsArray);
    static void processCyclopediaCharacterGeneralStatsBadge(const uint8_t showAccountInformation, const uint8_t playerOnline, const uint8_t playerPremium, 
                                                    const std::string_view loyaltyTitle,
                                                    const std::vector<std::tuple<uint32_t, std::string_view>>& badgesVector);
    static void processCyclopediaCharacterItemSummary(const CyclopediaCharacterItemSummary& data);
    static void processCyclopediaCharacterAppearances(const OutfitColorStruct& currentOutfit, const std::vector<CharacterInfoOutfits>& outfits, 
                                                    const std::vector<CharacterInfoMounts>& mounts, std::vector<CharacterInfoFamiliar>& familiars);
    static void processCyclopediaCharacterRecentDeaths(const CyclopediaCharacterRecentDeaths& data);
    static void processCyclopediaCharacterRecentPvpKills(const CyclopediaCharacterRecentPvPKills& data);
    static void processParseBestiaryRaces(const std::vector<CyclopediaBestiaryRace>& bestiaryData);
    static void processParseBestiaryOverview(const std::string_view raceName, const std::vector<BestiaryOverviewMonsters>& data,uint16_t animusMasteryPoints);
    static void processUpdateBestiaryMonsterData(const BestiaryMonsterData& data);
    static void processUpdateBestiaryCharmsData(const BestiaryCharmsData& charmData);
    static void processBosstiaryInfo(const std::vector<BosstiaryData>& boss);
    static void processBosstiarySlots(const BosstiarySlotsData& data);

    friend class ProtocolGame;
    friend class Map;

public:
    // login related
    void loginWorld(const std::string_view account, const std::string_view password, const std::string_view worldName, const std::string_view worldHost, int worldPort, const std::string_view characterName, const std::string_view authenticatorToken, const std::string_view sessionKey);
    void cancelLogin();
    void forceLogout();
    void safeLogout();

    // walk related
    bool walk(Otc::Direction direction, bool isKeyDown = false);
    void autoWalk(const std::vector<Otc::Direction>& dirs, const Position& startPos);
    void forceWalk(Otc::Direction direction);
    void turn(Otc::Direction direction);
    void stop();
    void setScheduleLastWalk(bool scheduleLastWalk) { m_scheduleLastWalk = scheduleLastWalk; }

    // item related
    void look(const ThingPtr& thing, bool isBattleList = false);
    void move(const ThingPtr& thing, const Position& toPos, int count);
    void moveToParentContainer(const ThingPtr& thing, int count);
    void rotate(const ThingPtr& thing);
    void wrap(const ThingPtr& thing);
    void use(const ThingPtr& thing);
    void useWith(const ItemPtr& item, const ThingPtr& toThing);
    void useInventoryItem(int itemId);
    void useInventoryItemWith(int itemId, const ThingPtr& toThing);
    ItemPtr findItemInContainers(uint32_t itemId, int subType);

    // container related
    int open(const ItemPtr& item, const ContainerPtr& previousContainer);
    void openParent(const ContainerPtr& container);
    void close(const ContainerPtr& container);
    void refreshContainer(const ContainerPtr& container);

    // attack/follow related
    void attack(CreaturePtr creature);
    void cancelAttack() { attack(nullptr); }
    void follow(CreaturePtr creature);
    void cancelFollow() { follow(nullptr); }
    void cancelAttackAndFollow();

    // talk related
    void talk(const std::string_view message);
    void talkChannel(Otc::MessageMode mode, int channelId, const std::string_view message);
    void talkPrivate(Otc::MessageMode mode, const std::string_view receiver, const std::string_view message);

    // channel related
    void openPrivateChannel(const std::string_view receiver);
    void requestChannels();
    void joinChannel(int channelId);
    void leaveChannel(int channelId);
    void closeNpcChannel();
    void openOwnChannel();
    void inviteToOwnChannel(const std::string_view name);
    void excludeFromOwnChannel(const std::string_view name);

    // party related
    void partyInvite(int creatureId);
    void partyJoin(int creatureId);
    void partyRevokeInvitation(int creatureId);
    void partyPassLeadership(int creatureId);
    void partyLeave();
    void partyShareExperience(bool active);

    // outfit related
    void requestOutfit();
    void changeOutfit(const Outfit& outfit);

    void sendTyping(bool typing);

    // vip related
    void addVip(const std::string_view name);
    void removeVip(int playerId);
    void editVip(int playerId, const std::string_view description, int iconId, bool notifyLogin);

    // fight modes related
    void setChaseMode(Otc::ChaseModes chaseMode);
    void setFightMode(Otc::FightModes fightMode);
    void setSafeFight(bool on);
    void setPVPMode(Otc::PVPModes pvpMode);
    Otc::ChaseModes getChaseMode() { return m_chaseMode; }
    Otc::FightModes getFightMode() { return m_fightMode; }
    bool isSafeFight() { return m_safeFight; }
    Otc::PVPModes getPVPMode() { return m_pvpMode; }

    // pvp related
    void setUnjustifiedPoints(UnjustifiedPoints unjustifiedPoints);
    UnjustifiedPoints getUnjustifiedPoints() { return m_unjustifiedPoints; };
    void setOpenPvpSituations(int openPvpSituations);
    int getOpenPvpSituations() { return m_openPvpSituations; }

    // npc trade related
    void inspectNpcTrade(const ItemPtr& item);
    void buyItem(const ItemPtr& item, int amount, bool ignoreCapacity, bool buyWithBackpack);
    void sellItem(const ItemPtr& item, int amount, bool ignoreEquipped);
    void closeNpcTrade();

    // player trade related
    void requestTrade(const ItemPtr& item, const CreaturePtr& creature);
    void inspectTrade(bool counterOffer, int index);
    void acceptTrade();
    void rejectTrade();

    // house window and editable items related
    void editText(uint32_t id, const std::string_view text);
    void editList(uint32_t id, int doorId, const std::string_view text);

    // rule violations (only gms)
    void openRuleViolation(const std::string_view reporter);
    void closeRuleViolation(const std::string_view reporter);
    void cancelRuleViolation();

    // reports
    void reportBug(const std::string_view comment);
    void reportRuleViolation(const std::string_view target, int reason, int action, const std::string_view comment, const std::string_view statement, int statementId, bool ipBanishment);
    void debugReport(const std::string_view a, const std::string_view b, const std::string_view c, const std::string_view d);

    // questlog related
    void requestQuestLog();
    void requestQuestLine(int questId);

    // 870 only
    void equipItem(const ItemPtr& item);
    void mount(bool mount);

    // 910 only
    void requestItemInfo(const ItemPtr& item, int index);

    // >= 970 modal dialog
    void answerModalDialog(uint32_t dialog, int button, int choice);

    // >= 984 browse field
    void browseField(const Position& position);
    void seekInContainer(int cid, int index);

    // >= 1080 ingame store
    void buyStoreOffer(int offerId, int productType, const std::string_view name = "");
    void requestTransactionHistory(int page, int entriesPerPage);
    void requestStoreOffers(const std::string_view categoryName, int serviceType = 0);
    void openStore(int serviceType = 0, const std::string_view category = "");
    void transferCoins(const std::string_view recipient, int amount);
    void openTransactionHistory(int entriesPerPage);

    //void reportRuleViolation2();
    void ping();
    void setPingDelay(int delay) { m_pingDelay = delay; }

    // otclient only
    void changeMapAwareRange(int xrange, int yrange);

    // dynamic support for game features
    void enableFeature(Otc::GameFeature feature) { m_features.set(feature, true); }
    void disableFeature(Otc::GameFeature feature) { m_features.set(feature, false); }
    void setFeature(Otc::GameFeature feature, bool enabled) { m_features.set(feature, enabled); }
    bool getFeature(Otc::GameFeature feature) { return m_features.test(feature); }

    void setProtocolVersion(int version);
    int getProtocolVersion() { return m_protocolVersion; }

    bool isUsingProtobuf() { return getProtocolVersion() >= 1281 && !getFeature(Otc::GameLoadSprInsteadProtobuf); }

    void setClientVersion(int version);
    int getClientVersion() { return m_clientVersion; }

    void setCustomOs(Otc::OperatingSystem_t os) { m_clientCustomOs = os; }
    Otc::OperatingSystem_t getOs();

    bool canPerformGameAction() const;
    bool checkBotProtection() const;
    bool isEnabledBotProtection() {
#ifdef BOT_PROTECTION
        return true;
#else
        return false;
#endif
    }

    bool isOnline() { return m_online; }
    bool isLogging() { return !m_online && m_protocolGame; }
    bool isDead() { return m_dead; }
    bool isAttacking() { return !!m_attackingCreature && !m_attackingCreature->isRemoved(); }
    bool isFollowing() { return !!m_followingCreature && !m_followingCreature->isRemoved(); }
    bool isConnectionOk() { return m_protocolGame && m_protocolGame->getElapsedTicksSinceLastRead() < 5000; }

    int getPing() { return m_ping; }
    ContainerPtr getContainer(int index) { return m_containers[index]; }
    stdext::map<int, ContainerPtr> getContainers() { return m_containers; }
    stdext::map<int, Vip> getVips() { return m_vips; }
    CreaturePtr getAttackingCreature() { return m_attackingCreature; }
    CreaturePtr getFollowingCreature() { return m_followingCreature; }
    void setServerBeat(int beat) { m_serverBeat = beat; }
    int getServerBeat() { return m_serverBeat; }
    void setCanReportBugs(bool enable) { m_canReportBugs = enable; }
    bool canReportBugs() { return m_canReportBugs; }
    void setExpertPvpMode(bool enable) { m_expertPvpMode = enable; }
    bool getExpertPvpMode() { return m_expertPvpMode; }
    LocalPlayerPtr getLocalPlayer() { return m_localPlayer; }
    ProtocolGamePtr getProtocolGame() { return m_protocolGame; }
    std::string getCharacterName() { return m_characterName; }
    std::string getWorldName() { return m_worldName; }
    std::vector<uint8_t > getGMActions() { return m_gmActions; }
    bool isGM() { return !m_gmActions.empty(); }
    Otc::Direction getLastWalkDir() { return m_lastWalkDir; }

    std::string formatCreatureName(const std::string_view name);
    int findEmptyContainerId();

    // market related
    void leaveMarket();
    void browseMarket(uint8_t browseId, uint16_t browseType);
    void createMarketOffer(uint8_t type, uint16_t itemId, uint8_t itemTier, uint16_t amount, uint64_t price, uint8_t anonymous);
    void cancelMarketOffer(uint32_t timestamp, uint16_t counter);
    void acceptMarketOffer(uint32_t timestamp, uint16_t counter, uint16_t amount);

    // prey related
    void preyAction(uint8_t slot, uint8_t actionType, uint16_t index);
    void preyRequest();

    // imbuing related
    void applyImbuement(uint8_t slot, uint32_t imbuementId, bool protectionCharm);
    void clearImbuement(uint8_t slot);
    void closeImbuingWindow();

    void enableTileThingLuaCallback(bool value) { m_tileThingsLuaCallback = value; }
    bool isTileThingLuaCallbackEnabled() { return m_tileThingsLuaCallback; }

    // stash related
    void stashWithdraw(uint16_t itemId, uint32_t count, uint8_t stackpos);

    // highscore related
    void requestHighscore(uint8_t action, uint8_t category, uint32_t vocation, const std::string& world, uint8_t worldType, uint8_t battlEye, uint16_t page, uint8_t totalPages);
    void processHighscore(const std::string& serverName, const std::string& world, uint8_t worldType, uint8_t battlEye,
                            const std::vector<std::tuple<uint32_t, std::string>>& vocations,
                            const std::vector<std::tuple<uint8_t, std::string>>& categories,
                            uint16_t page, uint16_t totalPages,
                            const std::vector<std::tuple<uint32_t, std::string, std::string, uint8_t, std::string, uint16_t, uint8_t, uint64_t>>& highscores, uint32_t entriesTs);
  
    // imbuement related
    void imbuementDurations(bool isOpen = false);
    void requestBless();
    void requestQuickLootBlackWhiteList(uint8_t filter, uint16_t size, const std::vector<uint16_t>& listedItems);
    void openContainerQuickLoot(uint8_t action, uint8_t category, const Position& pos, uint16_t itemId, uint8_t stackpos, bool useMainAsFallback);

    // cyclopedia related
    void inspectionNormalObject(const Position& position);
    void inspectionObject(const Otc::InspectObjectTypes inspectionType, const uint16_t itemId, const uint8_t itemCount);
    void requestBestiary();
    void requestBestiaryOverview(const std::string_view catName);
    void requestBestiarySearch(const uint16_t raceId);
    void requestSendBuyCharmRune(const uint8_t runeId, const uint8_t action, const uint16_t raceId);
    void requestSendCharacterInfo(const uint32_t playerId, const Otc::CyclopediaCharacterInfoType_t characterInfoType, const uint16_t entriesPerPage = 0, const uint16_t page = 0);
    void requestBosstiaryInfo();
    void requestBossSlootInfo();
    void requestBossSlotAction(const uint8_t action, const uint32_t raceId);
    void sendStatusTrackerBestiary(const uint16_t raceId, bool status);
protected:
    void enableBotCall() { m_denyBotCall = false; }
    void disableBotCall() { m_denyBotCall = true; }

private:
    void setAttackingCreature(const CreaturePtr& creature);
    void setFollowingCreature(const CreaturePtr& creature);

    LocalPlayerPtr m_localPlayer;
    CreaturePtr m_attackingCreature;
    CreaturePtr m_followingCreature;
    ProtocolGamePtr m_protocolGame;
    stdext::map<int, ContainerPtr> m_containers;
    stdext::map<int, Vip> m_vips;

    bool m_tileThingsLuaCallback{ false };
    bool m_online{ false };
    bool m_denyBotCall{ false };
    bool m_dead{ false };
    bool m_expertPvpMode;
    uint16_t m_serverBeat{ 50 };
    ticks_t m_ping{ -1 };
    uint32_t m_pingSent{ 0 };
    uint32_t m_pingReceived{ 0 };
    uint32_t m_seq{ 0 };

    stdext::timer m_pingTimer;
    Timer m_dashTimer;
    uint16_t m_pingDelay{ 1000 };
    Otc::FightModes m_fightMode{ Otc::FightBalanced };
    Otc::ChaseModes m_chaseMode{ Otc::DontChase };
    Otc::PVPModes m_pvpMode{ Otc::WhiteDove };
    Otc::Direction m_lastWalkDir;
    Otc::Direction m_nextScheduledDir;
    bool m_scheduleLastWalk{ false };
    UnjustifiedPoints m_unjustifiedPoints;
    bool m_safeFight{ true };
    bool m_canReportBugs{ false };
    std::vector<uint8_t > m_gmActions;
    std::string m_characterName;
    std::string m_worldName;
    std::bitset<Otc::LastGameFeature> m_features;
    ScheduledEventPtr m_pingEvent;
    ScheduledEventPtr m_walkEvent;
    ScheduledEventPtr m_checkConnectionEvent;
    bool m_connectionFailWarned;
    uint16_t m_protocolVersion{ 0 };
    uint16_t m_clientVersion{ 0 };
    uint8_t m_openPvpSituations{ 0 };
    std::string m_clientSignature;
    Otc::OperatingSystem_t m_clientCustomOs{ Otc::CLIENTOS_NONE };
};

extern Game g_game;
