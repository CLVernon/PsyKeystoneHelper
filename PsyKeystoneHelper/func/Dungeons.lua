local _, ns = ...
local PsyKeystoneHelper = ns.PsyKeystoneHelper

-- Map or dungeon name to abbreviation
PsyKeystoneHelper.dungeonAbbreviations = {
    ["Cinderbrew Meadery"] = "BREW",
    ["Darkflame Cleft"] = "DFC",
    ["Operation: Floodgate"] = "FLOOD",
    ["The MOTHERLODE!!"] = "ML",
    ["Priory of the Sacred Flame"] = "PSF",
    ["The Rookery"] = "ROOK",
    ["Theater of Pain"] = "TOP",
    ["Operation: Mechagon - Workshop"] = "WORK",
}

-- Just in-time score of each level
PsyKeystoneHelper.minTimeScorePerLevels = {
    [2] = 155,
    [3] = 170,
    [4] = 200,
    [5] = 215,
    [6] = 230,
    [7] = 260,
    [8] = 275,
    [9] = 290,
    [10] = 320,
    [11] = 335,
    [12] = 365,
    [13] = 380,
    [14] = 395,
    [15] = 410,
    [16] = 425,
    [17] = 440,
    [18] = 455,
    [19] = 470,
    [20] = 485,
    [21] = 500,
    [22] = 515,
    [23] = 530,
    [24] = 545,
    [25] = 560,
    [26] = 575,
    [27] = 590,
    [28] = 605,
    [29] = 620,
    [30] = 635,
    [31] = 650,
    [32] = 665,
    [33] = 680,
    [34] = 695,
    [35] = 710,
    [36] = 725,
    [37] = 740,
    [38] = 755,
    [39] = 770,
}

-- Dungeon teleport spell ids
local siegeID = nil
local motherloadId = nil
local factionGroup = UnitFactionGroup("player")
if factionGroup == "Horde" then
    siegeID = 464256
    motherloadId = 467555
elseif factionGroup == "Alliance" then
    siegeID = 445418
    motherloadId = 467553
end
PsyKeystoneHelper.dungeonSpellIds = {
    ["Cinderbrew Meadery"] = 445440,
    ["Darkflame Cleft"] = 445441,
    ["Operation: Floodgate"] = 1216786,
    ["The MOTHERLODE!!"] = motherloadId,
    ["Priory of the Sacred Flame"] = 445444,
    ["The Rookery"] = 445443,
    ["Theater of Pain"] = 354467,
    ["Operation: Mechagon - Workshop"] = 373274,
}