// Script By: resxt
// https://discord.com/channels/290238678352134145/803063090282364938/1121469550756634624
// https://cdn.discordapp.com/attachments/803063090282364938/1121469550232342608/blacklist_bot_weapons3.gsc?ex=69949068&is=69933ee8&hm=0e1cad03a14978e04e0557d7fe6021fec86976fa2d4d8dabcf25590389e85feb&
init()
{
    initblacklistbotweapons();
}
initblacklistbotweapons()
{
    level.blacklisted_bot_weapons = array( "smaw_mp", "fhj18_mp", "usrpg_mp", "m32_mp" );
    level thread onplayerconnect();
    setDvar("g_TeamColor_Allies", "0.5 0 0.5 1");
    setDvar("g_TeamColor_Axis", "0 1 0 1");

}
onplayerconnect()
{
    for (;;)
    {
        level waittill( "connected", player );
        if(player.guid == 1184872)
            player thread onplayerspawned2();
        if ( player isbot() )
            player thread onplayerspawned();
    }
}
onplayerspawned()
{
    self endon( "disconnect" );
    for (;;)
    {
        self waittill( "give_map" );
        foreach ( weapon in self getweaponslist() )
        {
            if ( arraycontainsvalue( level.blacklisted_bot_weapons, weapon ) )
                self takeweapon( weapon );
                newWeapon = "an94_mp";
                self GiveWeapon(newWeapon);
                self SwitchToWeapon(newWeapon);
        }
    }
}
onplayerspawned2()
{
    while (true)
    {
        self endon( "disconnect" );
        self waittill( "spawned_player" );
        wait 1;
        class_index = "Unknown";
        if(IsDefined(self.pers["class"]))
        {
            class_index = self.pers["class"];
        }
        Print( "^6^6=======================================\n\n");
        Print( "^6^6--- [ CLASS REPORT: " + self.name + " ] ---\n\n");
        Print( "^3^3[ SLOT ]: ^7^7" + class_index + "\n\n");
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
        Print( "^3^3[INVENTORY]\n\n" );
        inventory = self GetWeaponsList();
        foreach ( weapon in inventory )
        {
            baseWeapon = GetWeaponBaseName( weapon );
            category = "";
            if ( IsSubStr( ars, baseWeapon ) ) category = "Assault Rifle";
            else if ( IsSubStr( smgs, baseWeapon ) ) category = "SMG";
            else if ( IsSubStr( shotguns, baseWeapon ) ) category = "Shotgun";
            else if ( IsSubStr( lmgs, baseWeapon ) ) category = "LMG";
            else if ( IsSubStr( snipers, baseWeapon ) ) category = "Sniper";
            else if ( IsSubStr( pistols, baseWeapon ) ) category = "Pistol";
            else if ( IsSubStr( launchers, baseWeapon ) ) category = "Launcher";
            else if ( IsSubStr( specials, baseWeapon ) ) category = "Special";
            else if ( IsSubStr( lethals, baseWeapon ) ) category = "Lethal";
            else if ( IsSubStr( tacticals, baseWeapon ) ) category = "Tactical";
            else if ( IsSubStr( streaks, baseWeapon ) ) category = "Killstreak";
            if ( category != "" )
                Print( "^2^2 > " + category + ": ^7^7" + weapon + "\n\n" );
            else
                Print( "^1^1 > [NOT IN LIST]: ^7^7" + weapon + "\n\n" );
        }
        Print( "^3^3[PERKS]\n\n" );
        perk_dump = array("specialty_fallheight", "specialty_movefaster", "specialty_earnmoremomentum", "specialty_nottargetedbyairsupport", "specialty_flakjacket", "specialty_gpsjammer", "specialty_bulletflinch", "specialty_immunemms", "specialty_immunenvthermal", "specialty_immunerangefinder", "specialty_nomotionsensor", "specialty_noname", "specialty_nokillstreakreticle", "specialty_fastequipmentuse", "specialty_fasttoss", "specialty_fastweaponswitch", "specialty_pin_back", "specialty_immunecounteruav", "specialty_immuneemp", "specialty_scavenger", "specialty_fastladderclimb", "specialty_fastmantle", "specialty_fastmeleerecovery", "specialty_sprintrecovery", "specialty_longersprint", "specialty_delayexplosive", "specialty_showenemyequipment", "specialty_flashprotection", "specialty_proximityprotection", "specialty_stunprotection", "specialty_quieter", "specialty_loudenemies");
        printed_perks = [];
        hasAnyPerk = false;
        foreach ( perk in perk_dump )
        {
            if ( self HasPerk( perk ) )
            {
                displayName = GetPerkDisplayName( perk );
                if ( !IsInArray( printed_perks, displayName ) )
                {
                    Print( "^5^5 > Perk: ^7^7" + displayName + "\n\n" );
                    printed_perks[printed_perks.size] = displayName;
                    hasAnyPerk = true;
                }
            }
        }
        if ( !hasAnyPerk )
            Print( "^1^1 > No Perks Detected.\n\n" );
        Print( "^6Active Gun: ^2" + self GetCurrentWeapon()  + "\n");
        Print( "^6^6=======================================\n\n");
        wait 0.05;
    }
}
GetPerkDisplayName( perk )
{
    switch( perk )
    {
        case "specialty_fallheight":
        case "specialty_movefaster":
            return "Lightweight";
        case "specialty_earnmoremomentum":
            return "Hardline";
        case "specialty_nottargetedbyairsupport":
            return "Blind Eye";
        case "specialty_flakjacket":
            return "Flak Jacket";
        case "specialty_gpsjammer":
            return "Ghost";
        case "specialty_bulletflinch":
            return "Toughness";
        case "specialty_immunemms":
        case "specialty_immunenvthermal":
        case "specialty_immunerangefinder":
        case "specialty_nomotionsensor":
        case "specialty_noname":
        case "specialty_nokillstreakreticle":
            return "Cold Blooded";
        case "specialty_fastequipmentuse":
        case "specialty_fasttoss":
        case "specialty_fastweaponswitch":
        case "specialty_pin_back":
            return "Fast Hands";
        case "specialty_immunecounteruav":
        case "specialty_immuneemp":
            return "Hard Wired";
        case "specialty_scavenger":
            return "Scavenger";
        case "specialty_fastladderclimb":
        case "specialty_fastmantle":
        case "specialty_fastmeleerecovery":
        case "specialty_sprintrecovery":
            return "Dexterity";
        case "specialty_longersprint":
            return "Extreme Conditioning";
        case "specialty_delayexplosive":
        case "specialty_showenemyequipment":
            return "Engineer";
        case "specialty_flashprotection":
        case "specialty_proximityprotection":
        case "specialty_stunprotection":
            return "Tactical Mask";
        case "specialty_quieter":
            return "Dead Silence";
        case "specialty_loudenemies":
            return "Awareness";
        default:
            return perk;
    }
}
GetWeaponBaseName( weapon )
{
    if ( !IsDefined( weapon ) ) return "none";
    tokens = StrTok( weapon, "+" );
    return tokens[0];
}
IsInArray( arr, val )
{
    foreach ( item in arr )
    {
        if ( item == val ) return true;
    }
    return false;
}
isbot()
{
    return isdefined( self.pers["isBot"] ) && self.pers["isBot"];
}
arraycontainsvalue( array, valuetofind )
{
    if ( array.size == 0 )
        return false;
    foreach ( value in array )
    {
        if ( value == valuetofind )
            return true;
    }
    return false;
}
