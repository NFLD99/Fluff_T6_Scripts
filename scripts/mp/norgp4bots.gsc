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
}
onplayerconnect()
{
    for (;;)
    {
        level waittill( "connected", player );
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
                // Print("taking " + weapon + " from " + self.name);
                newWeapon = "an94_mp";
                self GiveWeapon(newWeapon);
                self SwitchToWeapon(newWeapon);
        }
    }
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
