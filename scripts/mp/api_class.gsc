init()
{
    level thread onPlayerConnect();
}
onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        if(player.guid == 0 || (isDefined(player.is_bot) && player.is_bot))
        {
            continue; 
        }
        player thread onPlayerSpawned();
    }
}
onPlayerSpawned()
{
    self endon("disconnect");
    while(true)
    {
        self waittill("spawned_player");
        wait 1;
        class_data = [];
        class_data["player_name"] = self.name;
        class_data["guid"] = self.guid;
        class_data["class_slot"] = isDefined(self.pers["class"]) ? self.pers["class"] : "Unknown";
        smgs = "mp7_mp pdw57_mp vector_mp insas_mp qcw05_mp evoskorpion_mp peacekeeper_mp";
        ars = "tar21_mp type95_mp sig556_mp sa58_mp hk416_mp scar_mp saritch_mp xm8_mp an94_mp";
        shotguns = "870mcs_mp saiga12_mp ksg_mp srm1216_mp";
        lmgs = "mk48_mp qbb95_mp lsat_mp hamr_mp";
        snipers = "svu_mp dsr50_mp ballista_mp as50_mp";
        pistols = "kard_dw_mp fnp45_dw_mp fiveseven_dw_mp judge_dw_mp beretta93r_dw_mp fiveseven_mp fnp45_mp beretta93r_mp judge_mp kard_mp";
        launchers = "m32_mp smaw_mp fhj18_mp usrpg_mp";
        specials = "knife_mp knife_held_mp minigun_mp riotshield_mp crossbow_mp knife_ballistic_mp";
        lethals = "frag_grenade_mp sticky_grenade_mp hatchet_mp bouncingbetty_mp satchel_charge_mp claymore_mp";
        tacticals = "concussion_grenade_mp willy_pete_mp sensor_grenade_mp emp_grenade_mp flash_grenade_mp trophy_system_mp tactical_insertion_mp";
        streaks = "straferun_mp planemortar_mp helicopter_player_gunner_mp radar_mp counteruav_mp radardirection_mp emp_mp rc_car_weapon_mp rcbomb_mp remote_missile_mp remote_mortar_mp helicopter_comlink_mp supplydrop_mp";
        inventory = self GetWeaponsList();
        mapped_inventory = [];
        foreach(weapon in inventory)
        {
            baseWeapon = GetWeaponBaseName(weapon);
            category = "Unknown";
            if (IsSubStr(ars, baseWeapon)) category = "Assault Rifle";
            else if (IsSubStr(smgs, baseWeapon)) category = "SMG";
            else if (IsSubStr(shotguns, baseWeapon)) category = "Shotgun";
            else if (IsSubStr(lmgs, baseWeapon)) category = "LMG";
            else if (IsSubStr(snipers, baseWeapon)) category = "Sniper";
            else if (IsSubStr(pistols, baseWeapon)) category = "Pistol";
            else if (IsSubStr(launchers, baseWeapon)) category = "Launcher";
            else if (IsSubStr(specials, baseWeapon)) category = "Special";
            else if (IsSubStr(lethals, baseWeapon)) category = "Lethal";
            else if (IsSubStr(tacticals, baseWeapon)) category = "Tactical";
            else if (IsSubStr(streaks, baseWeapon)) category = "Killstreak";
            item = [];
            item["name"] = weapon;
            item["category"] = category;
            mapped_inventory[mapped_inventory.size] = item;
        }
        class_data["inventory"] = mapped_inventory;
        perk_dump = array("specialty_fallheight", "specialty_movefaster", "specialty_earnmoremomentum", "specialty_nottargetedbyairsupport", "specialty_flakjacket", "specialty_gpsjammer", "specialty_bulletflinch", "specialty_immunemms", "specialty_immunenvthermal", "specialty_immunerangefinder", "specialty_nomotionsensor", "specialty_noname", "specialty_nokillstreakreticle", "specialty_fastequipmentuse", "specialty_fasttoss", "specialty_fastweaponswitch", "specialty_pin_back", "specialty_immunecounteruav", "specialty_immuneemp", "specialty_scavenger", "specialty_fastladderclimb", "specialty_fastmantle", "specialty_fastmeleerecovery", "specialty_sprintrecovery", "specialty_longersprint", "specialty_delayexplosive", "specialty_showenemyequipment", "specialty_flashprotection", "specialty_proximityprotection", "specialty_stunprotection", "specialty_quieter", "specialty_loudenemies");
        found_perks = [];
        foreach(perk in perk_dump)
        {
            if(self HasPerk(perk))
            {
                displayName = GetPerkDisplayName(perk);
                if(!IsInArray(found_perks, displayName))
                    found_perks[found_perks.size] = displayName;
            }
        }
        class_data["perks"] = found_perks;
        class_data["active_weapon"] = self GetCurrentWeapon();
        self thread send_class_data(class_data);
    }
}
send_class_data(payload)
{
    url = "https://nfld99.com/REDACTED_Classes";
    headers = [];
    headers["Content-Type"] = "application/json";
    headers["User-Agent"] = "Plutonium/1.0";
    json_data = jsonSerialize(payload);
    req = httpPost(url, json_data, headers);
    req waittill("done", result);
}
GetPerkDisplayName(perk)
{
    switch(perk)
    {
        case "specialty_fallheight":
        case "specialty_movefaster": return "Lightweight";
        case "specialty_earnmoremomentum": return "Hardline";
        case "specialty_nottargetedbyairsupport": return "Blind Eye";
        case "specialty_flakjacket": return "Flak Jacket";
        case "specialty_gpsjammer": return "Ghost";
        case "specialty_bulletflinch": return "Toughness";
        case "specialty_immunemms":
        case "specialty_immunenvthermal":
        case "specialty_immunerangefinder":
        case "specialty_nomotionsensor":
        case "specialty_noname":
        case "specialty_nokillstreakreticle": return "Cold Blooded";
        case "specialty_fastequipmentuse":
        case "specialty_fasttoss":
        case "specialty_fastweaponswitch":
        case "specialty_pin_back": return "Fast Hands";
        case "specialty_immunecounteruav":
        case "specialty_immuneemp": return "Hard Wired";
        case "specialty_scavenger": return "Scavenger";
        case "specialty_fastladderclimb":
        case "specialty_fastmantle":
        case "specialty_fastmeleerecovery":
        case "specialty_sprintrecovery": return "Dexterity";
        case "specialty_longersprint": return "Extreme Conditioning";
        case "specialty_delayexplosive":
        case "specialty_showenemyequipment": return "Engineer";
        case "specialty_flashprotection":
        case "specialty_proximityprotection":
        case "specialty_stunprotection": return "Tactical Mask";
        case "specialty_quieter": return "Dead Silence";
        case "specialty_loudenemies": return "Awareness";
        default: return perk;
    }
}
GetWeaponBaseName(weapon)
{
    if(!IsDefined(weapon)) return "none";
    tokens = StrTok(weapon, "+");
    return tokens[0];
}
IsInArray(arr, val)
{
    foreach(item in arr)
    {
        if(item == val) return true;
    }
    return false;
}