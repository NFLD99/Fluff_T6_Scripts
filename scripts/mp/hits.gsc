init()
{
    level.bone_threshold = 70;
    level thread onPlayerConnect();
}
onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        if(!isDefined(player.pers["stats_init"]))
        {
            player.pers["shots_fired"] = 0;
            player.pers["total_hits"] = 0;
            player.pers["bone_hits"] = Array();
            player.pers["bone_hits"]["head_zone"] = 0;
            player.pers["bone_hits"]["body_zone"] = 0;
            player.pers["stats_init"] = true;
        }
        player thread monitorShots();
        player thread monitorAttackerDamage();
        if(player.name == "MrFluff")
        {
            player thread testRunLoop();
        }
    }
}
monitorAttackerDamage()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("damage", amount, attacker, dir, point, type, tagName, modelName, partName, dflags, weapon);
        if(isDefined(attacker) && isPlayer(attacker))
        {
            // MANUAL COORDINATE CALCULATION
            // Calculate the height difference between the hit point and the victim's feet
            hitHeight = point[2] - self.origin[2];
            // T6 Average Heights: 
            // 0-35: Legs | 36-58: Torso | 59+: Head/Neck
            loc = "body_zone";
            if(hitHeight >= 58) 
            {
                loc = "head_zone";
            }
            // If the engine actually gives us a name, we use it, otherwise use our calculation
            if(isDefined(tagName) && tagName != "" && tagName != "none" && tagName != "unknown") 
            {
                loc = tagName;
            }
            attacker recordPlayerHit(loc, weapon);
        }
    }
}
recordPlayerHit(boneName, weaponName)
{
    self.pers["total_hits"]++;
    if(!isDefined(self.pers["bone_hits"][boneName]))
    {
        self.pers["bone_hits"][boneName] = 0;
    }
    self.pers["bone_hits"][boneName]++;
    self.pers["last_weapon"] = weaponName;
    if(boneName == "head_zone" || boneName == "head" || boneName == "j_head")
    {
        self thread checkBoneThreshold(boneName);
    }
}
monitorShots()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("weapon_fired");
        self.pers["shots_fired"]++;
    }
}
testRunLoop()
{
    self endon("disconnect");
    for(;;)
    {
        wait 60;
        self thread sendBoneAnalysisWebhook("TEST_RUN", 0);
    }
}
checkBoneThreshold(boneName)
{
    if(self.pers["total_hits"] < 15) return;
    hitCount = self.pers["bone_hits"][boneName];
    tHits = self.pers["total_hits"];
    percentage = (hitCount / tHits) * 100;
    if(percentage >= level.bone_threshold)
    {
        self thread sendBoneAnalysisWebhook(boneName, percentage);
    }
}
sendBoneAnalysisWebhook(flaggedBone, flagPercent)
{
    if(!isDefined(self)) return;
    if(flaggedBone != "TEST_RUN" && isDefined(self.webhook_cooldown)) return;
    if(flaggedBone != "TEST_RUN") self.webhook_cooldown = true;
    s_fired = self.pers["shots_fired"];
    s_hits = self.pers["total_hits"];
    s_missed = (s_fired - s_hits < 0) ? 0 : s_fired - s_hits;
    l_weapon = isDefined(self.pers["last_weapon"]) ? self.pers["last_weapon"] : "None";
    headers = Array();
    headers["Content-Type"] = "application/json";
    f1 = Array();
    f1["name"] = "Flagged Bone / Weapon";
    f1["value"] = flaggedBone + " (" + int(flagPercent) + "%) \nWeapon: " + l_weapon;
    f1["inline"] = true;
    f2 = Array();
    f2["name"] = "Shots Fired / Hit / Missed";
    f2["value"] = s_fired + " / " + s_hits + " / " + s_missed;
    f2["inline"] = true;
    boneBreakdown = "";
    keys = getArrayKeys(self.pers["bone_hits"]);
    for(i = 0; i < keys.size; i++)
    {
        b_key = keys[i];
        b_count = self.pers["bone_hits"][b_key];
        divisor = (s_hits <= 0) ? 1 : s_hits;
        b_perc = int((b_count / divisor) * 100);
        boneBreakdown = boneBreakdown + "**" + b_key + "**: " + b_perc + "% (" + b_count + " hits)\n";
    }
    f3 = Array();
    f3["name"] = "Full Bone Breakdown";
    f3["value"] = (boneBreakdown == "") ? "No hits yet." : boneBreakdown;
    f3["inline"] = false;
    embed = Array();
    embed["title"] = (flaggedBone == "TEST_RUN") ? "🧪 TEST REPORT: " + self.name : "🎯 ACCURACY ALERT: " + self.name;
    embed["description"] = "Coordinate-based height tracking for accurate bot detection.";
    embed["color"] = 15158528;
    embed["fields"] = Array();
    embed["fields"][0] = f1;
    embed["fields"][1] = f2;
    embed["fields"][2] = f3;
    data = Array();
    data["embeds"] = Array();
    data["embeds"][0] = embed;
    data["username"] = "Accuracy Watchdog";
    data["avatar_url"] = "https://static.wikia.nocookie.net/callofduty/images/a/a9/Tactical_Nuke_inventory_icon_MW2.gif";
    url = "https://discord.com/api/webhooks/[REDACTED]/[REDACTED]";
    req = httpPost(url, jsonSerialize(data, 0), headers);
    req waittill("done", result);
    if(flaggedBone != "TEST_RUN")
    {
        wait 120;
        self.webhook_cooldown = undefined;
    }
}