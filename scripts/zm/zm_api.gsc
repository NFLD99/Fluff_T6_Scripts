init()
{
    level thread watch_game_end();
}
watch_game_end()
{
    level waittill("intermission");
    wait 1.0;
    send_zm_stats();
}
send_zm_stats()
{
    url = "https://nfld99.com/REDACTED";
    headers = [];
    headers["Content-Type"] = "application/json";
    headers["User-Agent"] = "Plutonium/1.0";
    payload = [];
    payload["type"] = "zm";
    payload["mapname"] = GetDvar("mapname"); // Internal name (e.g., zm_transit, zm_highrise)
    payload["ui_mapname"] = GetDvar("ui_mapname"); // Localized map string
    payload["map_location"] = GetDvar("ui_zm_mapstartlocation"); // Critical for Green Run (town, farm, diner)
    payload["gametype"] = GetDvar("g_gametype"); // zsurvival, zclassic, zgrief, zcleansed
    payload["gamemode_group"] = GetDvar("ui_zm_gamemodegroup"); // Helps distinguish Survival vs Grief
    payload["round"] = level.round_number;
    players = getPlayers();
    playerList = [];
    for(i = 0; i < players.size; i++)
    {
        if(isDefined(players[i]))
        {
            playerList[playerList.size] = players[i].name;
        }
    }
    payload["players"] = playerList;
    json_data = jsonSerialize(payload);
    req = httpPost(url, json_data, headers);
    req waittill("done", result);
}