<div align="center">
    <h1>
        <img src="PsyKeystoneHelper/img/logo.png" alt="PsyKeystoneHelper Logo" width="50">
        PsyKeystoneHelper
        <img src="PsyKeystoneHelper/img/logo.png" alt="PsyKeystoneHelper Logo" width="50">
    </h1>
    <h4>
        Shows the top M+ keystone upgrades for the team and each players current score breakdown
    </h4>
    <p>
        <a href="https://www.curseforge.com/wow/addons/psy-keystone-helper">Curseforge</a>
        ·
        <a href="https://addons.wago.io/addons/psy-keystone-helper">Wago</a>
    </p>
</div>

---

## Description

Ever wanted a simple way of seeing which keystones your party have are an upgrade for the team?
Then look no further -- this addon will show you the top 3 keystones for score gain in your party, as well as a
breakdown of each party members score per dungeon.

**Note:** This addon uses addon communication to send details to each party member such as current keystone and score
breakdown and thus each member of the party needs to install this addon.

![Main Window](https://media.forgecdn.net/attachments/description/1243679/description_ddac1667-8cab-4cfe-8608-56d391ba38a1.png "Main Window")

## How To Use

A 'session state' is used in order to control if the player wishes to receive and display the incoming information from
party members, so that if you're pugging or playing with people without the addon - simple do not enable the session.

A session can be enabled by:

- Opening the Key Helper frame and clicking the `Toggle Session` button
- Right clicking the minimap icon
- Using the chat command `/pkh session`

Once in session, data received by party members will be cached and displayed in the Key Helper Frame.

## Feature List

- Data is syncronised automatically across all party members
- A minimap icon is included which has three interactions:
    - Show the Key Helper Frame
    - Output commands that can be used
    - Toggle the session state
- When the session is running, data is collected and displayed in the Key Helper Frame
    - Each players current score
    - Each players current keystone (This will show either the key, if the key should be rerolled at the next
      opportunity, or if the key is dead)
    - The breakdown of each players score per dungeon
    - The calculated top three keystones the group could run to gain score
    - A top keystone or player keystone can be clicked to 'Call Out' that key to the rest of the party. This then
      presents a UI to every member of the party to notify them of the dungeon and allow them to click the icon to
      teleport if the spell is known.
    - When a dungeon is completed, the Key Helper Frame will appear to help decide the next dungeon to go
    - When a dungeon is completed, a reminder frame will be shown if your keystone should be rerolled
- When entering a dungeon, a reminder frame that your current key matches the dungeon will be shown
- Commands, which can be prefix with either /pkh or /keyhelper
    - `/pkh` or `/pkh show` - Display the Key Helper Frame
    - `/pkh session` - Toggle the state of the session
    - `/pkh request` - Trigger a data request to the party
    - `/pkh send` - Trigger a sending of your data to the party
    - `/pkh version` - Show the current version and the received version from party members

---

## Documenting an Issue or Feature Request

[Create a new bug report](https://github.com/CLVernon/PsyKeystoneHelper/issues/new?template=bug_report.md)

[Create a new feature request](https://github.com/CLVernon/PsyKeystoneHelper/issues/new?template=feature_request.md)
