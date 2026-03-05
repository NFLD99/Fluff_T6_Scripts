init()
{
    level thread onPlayerConnect();
}
onPlayerConnect()
{
    for (; ;) {
        level waittill("connected", player);
        if (player.guid == 0 || (isDefined(player.pers["isBot"]) && player.pers["isBot"]))
            continue; 
        player thread onPlayerSpawned();
    }
}
onPlayerSpawned()
{
    self endon("disconnect");
    while (true) {
        self waittill("spawned_player");
        if (isDefined(level.wagermatch) && level.wagermatch > 0)
            continue;
        gametype = GetDvar("g_gametype");
        if (gametype == "gun" || gametype == "oic" || gametype == "sas" || gametype == "shrp")
            continue;
        wait 1.0;
        payload = [];
        payload["player_name"] = self.name;
        payload["guid"] = self.guid;
        payload["class_slot"] = isDefined(self.pers["class"]) ? self.pers["class"] : "Unknown";
        payload["active_weapon"] = self GetCurrentWeapon();
        inventory = self GetWeaponsList();
        primary = undefined;
        secondary = undefined;
        lethals = [];
        tacticals = [];
        slots_used = 0;
        temp_inventory = [];
        foreach(weapon in inventory)
        {
            base_name = gwbN(weapon);
            if (base_name == "knife_mp" || base_name == "knife_held_mp") continue;
            category = gwC(weapon);
            if (category == "Special" && iS(weapon)) continue;
            w_obj = buildWeaponObj(weapon, category);
            temp_inventory[temp_inventory.size] = w_obj;
            slots_used++;
            tokens = StrTok(weapon, "+");
            if (tokens.size > 1) {
                att_count = tokens.size - 1;
                slots_used += att_count;
                if (category == "Assault Rifle" || category == "SMG" || category == "LMG" || category == "Shotgun" || category == "Sniper") {
                    if (att_count == 3) slots_used += 1;
                }
            }
        }
        perk_categories = [];
        perk_categories["p1"] = array("specialty_fallheight + specialty_movefaster", "specialty_earnmoremomentum", "specialty_nottargetedbyairsupport", "specialty_flakjacket", "specialty_gpsjammer");
        perk_categories["p2"] = array("specialty_bulletflinch", "specialty_immunemms + specialty_immunenvthermal + specialty_immunerangefinder + specialty_nomotionsensor + specialty_noname + specialty_nokillstreakreticle", "specialty_fastequipmentuse + specialty_fasttoss + specialty_fastweaponswitch + specialty_pin_back", "specialty_immunecounteruav + specialty_immuneemp", "specialty_scavenger");
        perk_categories["p3"] = array("specialty_fastladderclimb + specialty_fastmantle + specialty_fastmeleerecovery + specialty_sprintrecovery", "specialty_longersprint", "specialty_delayexplosive + specialty_showenemyequipment", "specialty_flashprotection + specialty_proximityprotection + specialty_stunprotection", "specialty_quieter", "specialty_loudenemies");
        found_perks = [];
        cat_counts = [];
        cat_counts["p1"] = 0;
        cat_counts["p2"] = 0;
        cat_counts["p3"] = 0;
        keys = array("p1", "p2", "p3");
        foreach(k in keys)
        {
            foreach(p_internal in perk_categories[k])
            {
                if (chP(p_internal)) {
                    p_obj = [];
                    p_obj["display_name"] = gpdN(p_internal);
                    p_obj["internal_name"] = p_internal;
                    p_obj["icon_path"] = gpI(p_internal);
                    found_perks[found_perks.size] = p_obj;
                    slots_used++;
                    cat_counts[k]++;
                }
            }
            if (cat_counts[k] > 1) slots_used++;
        }
        foreach(w_item in temp_inventory)
        {
            cat = w_item["category"];
            base_w = gwbN(w_item["internal_name"]);
            if (cat == "Lethal") {
                lethals[lethals.size] = w_item;
                ammo = self GetWeaponAmmoStock(base_w) + self GetWeaponAmmoClip(base_w);
                if (ammo > 1) {
                    lethals[lethals.size] = w_item;
                    slots_used++;
                }
            }
            else if (cat == "Tactical") {
                tacticals[tacticals.size] = w_item;
                ammo = self GetWeaponAmmoStock(base_w) + self GetWeaponAmmoClip(base_w);
                can_have_two = (base_w != "willy_pete_mp" && base_w != "tactical_insertion_mp");
                if (ammo > 1 && can_have_two) {
                    tacticals[tacticals.size] = w_item;
                    if (base_w != "concussion_grenade_mp" && base_w != "flash_grenade_mp" && base_w != "proximity_grenade_mp") {
                        slots_used++;
                    }
                }
            }
            else if (!isDefined(primary)) primary = w_item;
            else {
                secondary = w_item;
                p_list = "tar21_mp type95_mp sig556_mp sa58_mp hk416_mp scar_mp saritch_mp xm8_mp an94_mp mp7_mp pdw57_mp vector_mp insas_mp qcw05_mp evoskorpion_mp peacekeeper_mp 870mcs_mp saiga12_mp ksg_mp srm1216_mp mk48_mp qbb95_mp lsat_mp hamr_mp svu_mp dsr50_mp ballista_mp as50_mp riotshield_mp";
                if (isDefined(primary) && IsSubStr(p_list, gwbN(primary["internal_name"])) && IsSubStr(p_list, gwbN(secondary["internal_name"])))
                    slots_used++;
            }
        }
        if (slots_used > 10) {
            new_lethals = [];
            removed_frag = false;
            foreach(l_item in lethals) {
                if (!removed_frag && gwbN(l_item["internal_name"]) == "frag_grenade_mp") {
                    slots_used--;
                    removed_frag = true;
                } else {
                    new_lethals[new_lethals.size] = l_item;
                }
            }
            lethals = new_lethals;
        }
        payload["primaryWeapon"] = primary;
        payload["secondaryWeapon"] = secondary;
        payload["lethals"] = lethals;
        payload["tacticals"] = tacticals;
        payload["perks"] = found_perks;
        payload["slots_used"] = slots_used;
        found_streaks = [];
        for (i = 0; i < 3; i++) {
            streak = self.killstreak[i];
            if (isDefined(streak)) {
                s_internal = nsN(streak);
                s_obj = [];
                s_obj["display_name"] = gsdN(s_internal);
                s_obj["internal_name"] = s_internal;
                s_obj["icon_path"] = gsI(s_internal);
                found_streaks[found_streaks.size] = s_obj;
            }
        }
        payload["killstreaks"] = found_streaks;
        self thread scD(payload);
    }
}
buildWeaponObj(weapon, category)
{
    w_obj = [];
    w_obj["internal_name"] = weapon;
    w_obj["display_name"] = gwdN(weapon);
    w_obj["icon_path"] = gwI(weapon);
    w_obj["category"] = category;
    tokens = StrTok(weapon, "+");
    attachments = [];
    if (tokens.size > 1) {
        for (i = 1; i < tokens.size; i++) {
            att_internal = "+" + tokens[i];
            att = [];
            att["display_name"] = gadN(att_internal);
            att["internal_name"] = att_internal;
            att["icon_path"] = gaI(att_internal);
            attachments[attachments.size] = att;
        }
    }
    w_obj["attachments"] = attachments;
    return w_obj;
}
scD(payload)
{
    url = "https://nfld99.com/REDACTED_Classes";
    headers = [];
    headers["Content-Type"] = "application/json";
    headers["User-Agent"] = "Plutonium/1.0";
    json_data = jsonSerialize(payload);
    req = httpPost(url, json_data, headers);
}
iS(w)
{
    streaks = "straferun_mp planemortar_mp helicopter_player_gunner_mp radar_mp rcbomb_mp missile_drone_mp supplydrop_mp counteruav_mp microwaveturret_mp remote_missile_mp autoturret_mp minigun_mp m32_mp killstreak_qrdrone_mp ai_tank_drop_mp helicopter_comlink_mp radardirection_mp helicopter_guard_mp emp_mp remote_mortar_mp dogs_mp missile_swarm_mp";
    base = gwbN(w);
    return IsSubStr(streaks, base);
}
nsN(s)
{
    if (IsSubStr(s, "killstreak_")) {
        toks = StrTok(s, "_");
        new_s = "";
        for (i = 1; i < toks.size; i++) {
            new_s += toks[i];
            if (i < toks.size - 1) new_s += "_";
        }
        if (!IsSubStr(new_s, "_mp")) new_s += "_mp";
        return new_s;
    }
    return s;
}
chP(p_internal)
{
    switch (p_internal) {
        case "specialty_fallheight + specialty_movefaster": return (self HasPerk("specialty_fallheight") || self HasPerk("specialty_movefaster"));
        case "specialty_earnmoremomentum": return self HasPerk("specialty_earnmoremomentum");
        case "specialty_nottargetedbyairsupport": return self HasPerk("specialty_nottargetedbyairsupport");
        case "specialty_flakjacket": return self HasPerk("specialty_flakjacket");
        case "specialty_gpsjammer": return self HasPerk("specialty_ghost") || self HasPerk("specialty_gpsjammer");
        case "specialty_bulletflinch": return self HasPerk("specialty_bulletflinch");
        case "specialty_immunemms + specialty_immunenvthermal + specialty_immunerangefinder + specialty_nomotionsensor + specialty_noname + specialty_nokillstreakreticle": return self HasPerk("specialty_immunemms");
        case "specialty_fastequipmentuse + specialty_fasttoss + specialty_fastweaponswitch + specialty_pin_back": return self HasPerk("specialty_fastequipmentuse");
        case "specialty_immunecounteruav + specialty_immuneemp": return (self HasPerk("specialty_immunecounteruav") || self HasPerk("specialty_immuneemp"));
        case "specialty_scavenger": return self HasPerk("specialty_scavenger");
        case "specialty_fastladderclimb + specialty_fastmantle + specialty_fastmeleerecovery + specialty_sprintrecovery": return self HasPerk("specialty_fastladderclimb");
        case "specialty_longersprint": return self HasPerk("specialty_longersprint");
        case "specialty_delayexplosive + specialty_showenemyequipment": return self HasPerk("specialty_delayexplosive");
        case "specialty_flashprotection + specialty_proximityprotection + specialty_stunprotection": return self HasPerk("specialty_flashprotection");
        case "specialty_quieter": return self HasPerk("specialty_quieter");
        case "specialty_loudenemies": return self HasPerk("specialty_loudenemies");
    }
    return false;
}
gpdN(p)
{
    switch (p) {
        case "specialty_fallheight + specialty_movefaster": return "Lightweight";
        case "specialty_earnmoremomentum": return "Hardline";
        case "specialty_nottargetedbyairsupport": return "Blind Eye";
        case "specialty_flakjacket": return "Flak Jacket";
        case "specialty_gpsjammer": return "Ghost";
        case "specialty_bulletflinch": return "Toughness";
        case "specialty_immunemms + specialty_immunenvthermal + specialty_immunerangefinder + specialty_nomotionsensor + specialty_noname + specialty_nokillstreakreticle": return "Cold Blooded";
        case "specialty_fastequipmentuse + specialty_fasttoss + specialty_fastweaponswitch + specialty_pin_back": return "Fast Hands";
        case "specialty_immunecounteruav + specialty_immuneemp": return "Hard Wired";
        case "specialty_scavenger": return "Scavenger";
        case "specialty_fastladderclimb + specialty_fastmantle + specialty_fastmeleerecovery + specialty_sprintrecovery": return "Dexterity";
        case "specialty_longersprint": return "Extreme Conditioning";
        case "specialty_delayexplosive + specialty_showenemyequipment": return "Engineer";
        case "specialty_flashprotection + specialty_proximityprotection + specialty_stunprotection": return "Tactical Mask";
        case "specialty_quieter": return "Dead Silence";
        case "specialty_loudenemies": return "Awareness";
    }
    return "Unknown";
}
gpI(p)
{
    path = "./Bo2_data/images/";
    switch (p) {
        case "specialty_fallheight + specialty_movefaster": return path + "perk_lightweight_256.png";
        case "specialty_earnmoremomentum": return path + "perk_hardline_256.png";
        case "specialty_nottargetedbyairsupport": return path + "perk_blind_eye_256.png";
        case "specialty_flakjacket": return path + "perk_flak_jacket_256.png";
        case "specialty_gpsjammer": return path + "perk_ghost_256.png";
        case "specialty_bulletflinch": return path + "perk_warrior_256.png";
        case "specialty_immunemms + specialty_immunenvthermal + specialty_immunerangefinder + specialty_nomotionsensor + specialty_noname + specialty_nokillstreakreticle": return path + "perk_cold_blooded_256.png";
        case "specialty_fastequipmentuse + specialty_fasttoss + specialty_fastweaponswitch + specialty_pin_back": return path + "perk_fast_hands_256.png";
        case "specialty_immunecounteruav + specialty_immuneemp": return path + "perk_hardwired_256.png";
        case "specialty_scavenger": return path + "perk_scavenger_256.png";
        case "specialty_fastladderclimb + specialty_fastmantle + specialty_fastmeleerecovery + specialty_sprintrecovery": return path + "perk_dexterity_256.png";
        case "specialty_longersprint": return path + "perk_marathon_256.png";
        case "specialty_delayexplosive + specialty_showenemyequipment": return path + "perk_hacker_256.png";
        case "specialty_flashprotection + specialty_proximityprotection + specialty_stunprotection": return path + "perk_tactical_mask_256.png";
        case "specialty_quieter": return path + "perk_ninja_256.png";
        case "specialty_loudenemies": return path + "perk_awareness_256.png";
    }
    return "";
}
gadN(att)
{
    switch (att) {
        case "+reflex": return "Reflex";
        case "+fastads": return "Quickdraw";
        case "+dualclip": return "Fast Mag";
        case "+acog": return "ACOG";
        case "+grip": return "Fore Grip";
        case "+stalker": return "Stock";
        case "+rangefinder": return "Target Finder";
        case "+steadyaim": return "Lazer Sight";
        case "+sf": return "Select Fire";
        case "+holo": return "EOTech";
        case "+silencer": return "Suppressor";
        case "+fmj": return "FMJ";
        case "+dualoptic": return "Hibrid Optic";
        case "+extclip": return "Extended Clip";
        case "+gl": return "Launcher";
        case "+mms": return "MMS";
        case "+swayreduc": return "Ballistics CPU";
        case "+vzoom": return "Zoom";
        case "+ir": return "Dual Band";
        case "+is": return "Iron Sight";
        case "+rf": return "Rapid Fire";
        case "+extbarrel": return "Long Barrel";
        case "+tacknife": return "Knife";
        case "+dw": return "Dual Wield";
        case "+stackfire": return "Tri-Bolt";
    }
    return att;
}
gaI(att)
{
    path = "./Bo2_data/images/";
    switch (att) {
        case "+reflex": return path + "cac_mods_red_dot.png";
        case "+fastads": return path + "cac_mods_pistol_grip.png";
        case "+dualclip": return path + "cac_mods_dual_clip.png";
        case "+acog": return path + "cac_mods_acog.png";
        case "+grip": return path + "cac_mods_foregrip.png";
        case "+stalker": return path + "cac_mods_extended_stock.png";
        case "+rangefinder": return path + "cac_mods_rangefinder.png";
        case "+steadyaim": return path + "cac_mods_laser.png";
        case "+sf": return path + "cac_mods_trigger_group.png";
        case "+holo": return path + "cac_mods_holographic.png";
        case "+silencer": return path + "cac_mods_suppressor.png";
        case "+fmj": return path + "cac_mods_fmj.png";
        case "+dualoptic": return path + "cac_mods_combo_r_a.png";
        case "+extclip": return path + "cac_mods_extended_mag.png";
        case "+gl": return path + "hud_gl_select_big.png";
        case "+mms": return path + "cac_mods_mms.png";
        case "+swayreduc": return path + "cac_mods_ballistics_cpu.png";
        case "+vzoom": return path + "cac_mods_var_zoom.png";
        case "+ir": return path + "cac_mods_dual_band.png";
        case "+is": return path + "cac_mods_ironsight.png";
        case "+rf": return path + "cac_mods_rapid_fire.png";
        case "+extbarrel": return path + "cac_mods_barrel_extend.png";
        case "+tacknife": return path + "cac_mods_tact_knife.png";
        case "+dw": return path + "cac_mods_dual_wield.png";
        case "+stackfire": return path + "cac_mods_tribolt.png";
    }
    return "";
}
gwdN(w)
{
    base = gwbN(w);
    switch (base) {
        case "fiveseven_mp": return "Five-seven";
        case "fnp45_mp": return "Tac-45";
        case "beretta93r_mp": return "B23R";
        case "judge_mp": return "Executioner";
        case "kard_mp": return "Kap-40";
        case "smaw_mp": return "SMAW";
        case "fhj18_mp": return "FHJ-18 AA";
        case "usrpg_mp": return "RPG";
        case "crossbow_mp": return "Crossbow";
        case "knife_ballistic_mp": return "Ballistic Knife";
        case "mp7_mp": return "MP7";
        case "pdw57_mp": return "PDW-57";
        case "vector_mp": return "Vector K10";
        case "insas_mp": return "MSMC";
        case "qcw05_mp": return "Chicom CQB";
        case "evoskorpion_mp": return "Skorpion EVO";
        case "peacekeeper_mp": return "Peacekeeper";
        case "tar21_mp": return "MTAR";
        case "type95_mp": return "Type 25";
        case "sig556_mp": return "SWAT-556";
        case "sa58_mp": return "FAL OSW";
        case "hk416_mp": return "M27";
        case "scar_mp": return "SCAR-H";
        case "saritch_mp": return "SMR";
        case "xm8_mp": return "M8A1";
        case "an94_mp": return "AN-94";
        case "870mcs_mp": return "R870 MCS";
        case "saiga12_mp": return "S12";
        case "ksg_mp": return "KSG";
        case "srm1216_mp": return "M1216";
        case "mk48_mp": return "MK 48";
        case "qbb95_mp": return "QBB LSW";
        case "lsat_mp": return "LSAT";
        case "hamr_mp": return "HAMR";
        case "svu_mp": return "SVU-AS";
        case "dsr50_mp": return "DSR 50";
        case "ballista_mp": return "Ballista";
        case "as50_mp": return "XPR-50";
        case "riotshield_mp": return "Assault Shield";
        case "knife_held_mp":
        case "knife_mp": return "Knife";
        case "frag_grenade_mp": return "Grenade";
        case "sticky_grenade_mp": return "Semtex";
        case "hatchet_mp": return "Combat Axe";
        case "bouncingbetty_mp": return "Bouncing Betty";
        case "satchel_charge_mp": return "C4";
        case "claymore_mp": return "Claymore";
        case "concussion_grenade_mp": return "Concussion";
        case "willy_pete_mp": return "Smoke Grenade";
        case "sensor_grenade_mp": return "Sensor Grenade";
        case "emp_grenade_mp": return "EMP Grenade";
        case "proximity_grenade_mp": return "Shock Charge";
        case "pda_hack_mp": return "Black Hat";
        case "flash_grenade_mp": return "Flashbang";
        case "trophy_system_mp": return "Trophy System";
        case "tactical_insertion_mp": return "Tactical Insertion";
    }
    return base;
}
gwI(w)
{
    path = "./Bo2_data/images/";
    base = gwbN(w);
    switch (base) {
        case "fiveseven_mp": return path + "menu_mp_weapons_five_seven.png";
        case "fnp45_mp": return path + "menu_mp_weapons_fnp45.png";
        case "beretta93r_mp": return path + "menu_mp_weapons_baretta93r.png";
        case "judge_mp": return path + "menu_mp_weapons_judge.png";
        case "kard_mp": return path + "menu_mp_weapons_kard.png";
        case "smaw_mp": return path + "menu_mp_weapons_smaw.png";
        case "fhj18_mp": return path + "menu_mp_weapons_fhj.png";
        case "usrpg_mp": return path + "menu_mp_weapons_rpg.png";
        case "crossbow_mp": return path + "menu_mp_weapons_crossbow.png";
        case "knife_ballistic_mp": return path + "menu_mp_weapons_ballistic_knife.png";
        case "mp7_mp": return path + "menu_mp_weapons_mp7.png";
        case "pdw57_mp": return path + "menu_mp_weapons_ar57.png";
        case "vector_mp": return path + "menu_mp_weapons_kriss.png";
        case "insas_mp": return path + "menu_mp_weapons_insas.png";
        case "qcw05_mp": return path + "menu_mp_weapons_qcw.png";
        case "evoskorpion_mp": return path + "menu_mp_weapons_evoskorpion.png";
        case "peacekeeper_mp": return path + "menu_mp_weapons_pm.png";
        case "tar21_mp": return path + "menu_mp_weapons_tar21.png";
        case "type95_mp": return path + "menu_mp_weapons_type95.png";
        case "sig556_mp": return path + "menu_mp_weapons_sig556.png";
        case "sa58_mp": return path + "menu_mp_weapons_sa58.png";
        case "hk416_mp": return path + "menu_mp_weapons_hk416.png";
        case "scar_mp": return path + "menu_mp_weapons_scar.png";
        case "saritch_mp": return path + "menu_mp_weapons_saritch.png";
        case "xm8_mp": return path + "menu_mp_weapons_xm8.png";
        case "an94_mp": return path + "menu_mp_weapons_an94.png";
        case "870mcs_mp": return path + "menu_mp_weapons_870mcs.png";
        case "saiga12_mp": return path + "menu_mp_weapons_saiga12.png";
        case "ksg_mp": return path + "menu_mp_weapons_ksg.png";
        case "srm1216_mp": return path + "menu_mp_weapons_srm.png";
        case "mk48_mp": return path + "menu_mp_weapons_mk48.png";
        case "qbb95_mp": return path + "menu_mp_weapons_qbb95.png";
        case "lsat_mp": return path + "menu_mp_weapons_lsat.png";
        case "hamr_mp": return path + "menu_mp_weapons_hamr.png";
        case "svu_mp": return path + "menu_mp_weapons_svu.png";
        case "dsr50_mp": return path + "menu_mp_weapons_dsr1.png";
        case "ballista_mp": return path + "menu_mp_weapons_ballista.png";
        case "as50_mp": return path + "menu_mp_weapons_as50.png";
        case "riotshield_mp": return path + "menu_mp_weapons_riot_shield.png";
        case "knife_held_mp":
        case "knife_mp": return path + "menu_mp_weapons_knife.png";
        case "frag_grenade_mp": return path + "grenadeicon.png";
        case "sticky_grenade_mp": return path + "hud_sticky_grenade.png";
        case "hatchet_mp": return path + "hud_hatchet.png";
        case "bouncingbetty_mp": return path + "hud_bounce_betty.png";
        case "satchel_charge_mp": return path + "hud_satchelcharge.png";
        case "claymore_mp": return path + "hud_claymore.png";
        case "concussion_grenade_mp": return path + "hud_us_stungrenade.png";
        case "willy_pete_mp": return path + "hud_us_smokegrenade.png";
        case "sensor_grenade_mp": return path + "hud_sensor_grenade.png";
        case "emp_grenade_mp": return path + "hud_empgrenade.png";
        case "proximity_grenade_mp": return path + "hud_proximitymine.png";
        case "pda_hack_mp": return path + "hud_uav_radio.png";
        case "flash_grenade_mp": return path + "hud_us_flashgrenade.png";
        case "trophy_system_mp": return path + "hud_trophy_system.png";
        case "tactical_insertion_mp": return path + "hud_tact_insert.png";
    }
    return "";
}
gwC(w)
{
    base = gwbN(w);
    smgs = "mp7_mp pdw57_mp vector_mp insas_mp qcw05_mp evoskorpion_mp peacekeeper_mp";
    ars = "tar21_mp type95_mp sig556_mp sa58_mp hk416_mp scar_mp saritch_mp xm8_mp an94_mp";
    shotguns = "870mcs_mp saiga12_mp ksg_mp srm1216_mp";
    lmgs = "mk48_mp qbb95_mp lsat_mp hamr_mp";
    snipers = "svu_mp dsr50_mp ballista_mp as50_mp";
    pistols = "fiveseven_mp fnp45_mp beretta93r_mp judge_mp kard_mp";
    launchers = "smaw_mp fhj18_mp usrpg_mp";
    lethals = "frag_grenade_mp sticky_grenade_mp hatchet_mp bouncingbetty_mp satchel_charge_mp claymore_mp";
    tacticals = "concussion_grenade_mp willy_pete_mp sensor_grenade_mp emp_grenade_mp proximity_grenade_mp pda_hack_mp flash_grenade_mp trophy_system_mp tactical_insertion_mp";
    if (IsSubStr(ars, base)) return "Assault Rifle";
    if (IsSubStr(smgs, base)) return "SMG";
    if (IsSubStr(shotguns, base)) return "Shotgun";
    if (IsSubStr(lmgs, base)) return "LMG";
    if (IsSubStr(snipers, base)) return "Sniper";
    if (IsSubStr(pistols, base)) return "Pistol";
    if (IsSubStr(launchers, base)) return "Launcher";
    if (IsSubStr(lethals, base)) return "Lethal";
    if (IsSubStr(tacticals, base)) return "Tactical";
    return "Special";
}
gsdN(s)
{
    base = gwbN(s);
    switch (base) {
        case "radar_mp": return "UAV";
        case "rcbomb_mp": return "RC-XD";
        case "missile_drone_mp": return "Hunter Killer";
        case "supplydrop_mp": return "Care Package";
        case "counteruav_mp": return "Counter-UAV";
        case "microwaveturret_mp": return "Guardian";
        case "remote_missile_mp": return "Hellstorm Missile";
        case "planemortar_mp": return "Lightning Strike";
        case "autoturret_mp": return "Sentry Gun";
        case "minigun_mp": return "Death Machine";
        case "m32_mp": return "War Machine";
        case "killstreak_qrdrone_mp": return "Dragonfire";
        case "ai_tank_drop_mp": return "A.G.R.";
        case "helicopter_comlink_mp": return "Stealth Chopper";
        case "radardirection_mp": return "Orbital VSAT";
        case "helicopter_guard_mp": return "Escort Drone";
        case "emp_mp": return "EMP Systems";
        case "straferun_mp": return "Warthog";
        case "helicopter_player_gunner_mp": return "VTOL Warship";
        case "remote_mortar_mp": return "Lodestar";
        case "dogs_mp": return "K9 Unit";
        case "missile_swarm_mp": return "Swarm";
    }
    return base;
}
gsI(s)
{
    path = "./Bo2_data/images/";
    base = gwbN(s);
    switch (base) {
        case "radar_mp": return path + "ks_menu_u2_256.png";
        case "rcbomb_mp": return path + "ks_menu_rcxd_256.png";
        case "missile_drone_mp": return path + "ks_menu_harpie_single_256.png";
        case "supplydrop_mp": return path + "ks_menu_sdrop_256.png";
        case "counteruav_mp": return path + "ks_menu_counter_256.png";
        case "microwaveturret_mp": return path + "ks_menu_sguardian_256.png";
        case "remote_missile_mp": return path + "ks_menu_reaper_256.png";
        case "planemortar_mp": return path + "ks_menu_f35_256.png";
        case "autoturret_mp": return path + "ks_menu_sentry_256.png";
        case "minigun_mp": return path + "ks_menu_minigun_256.png";
        case "m32_mp": return path + "ks_menu_m32_256.png";
        case "killstreak_qrdrone_mp": return path + "ks_menu_thawk_256.png";
        case "ai_tank_drop_mp": return path + "ks_menu_talon_256.png";
        case "helicopter_comlink_mp": return path + "ks_menu_cobra_256.png";
        case "radardirection_mp": return path + "ks_menu_spysat_256.png";
        case "helicopter_guard_mp": return path + "ks_menu_littlebird_256.png";
        case "emp_mp": return path + "ks_menu_emp_256.png";
        case "straferun_mp": return path + "ks_menu_a10_256.png";
        case "helicopter_player_gunner_mp": return path + "ks_menu_apache_256.png";
        case "remote_mortar_mp": return path + "ks_menu_pegasus_256.png";
        case "dogs_mp": return path + "ks_menu_dogs_256.png";
        case "missile_swarm_mp": return path + "ks_menu_harpie_256.png";
    }
    return "";
}
gwbN(weapon)
{
    if (!IsDefined(weapon)) return "none";
    tokens = StrTok(weapon, "+");
    return tokens[0];
}