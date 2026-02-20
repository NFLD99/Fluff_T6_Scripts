// Sript By MrFluff
// https://github.com/NFLD99/Fluff_T6_Scripts 
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
init()
{
    setDvar("jump_slowdownEnable", "0");
    setDvar("player_sprintUnlimited", 1);
    level.nuke_requirement = 25;
    level.nuke_in_progress = false;
    level.nuke_cooldown_timer = 0;
    level._effect["emp_flash"] = 74;
    if ( !isDefined( level.prevCallbackPlayerKilled ) )
    {
        level.prevCallbackPlayerKilled = level.callbackPlayerKilled;
        level.callbackPlayerKilled = ::Callback_PlayerKilled_NukeMonitor;
    }
    level thread onPlayerConnect();
    level thread setmovemntdvars();
}
onPlayerConnect()
{
    for(;;)
    {
        level waittill( "connected", player );
        player.nukes_earned = 0;
        player.nukes_used = 0;
        player.real_streak = 0;
        player.nuke_milestone = 1;
        player thread displayWelcomeMessage();
        player thread onPlayerSpawned();
        player thread monitorNukeEarning();
    }
}
setmovemntdvars(){
    buff_percent = 5;
    factor = 1 + buff_percent / 100;
    setdvar("player_backSpeedScale", 0.7 * factor);
    setdvar("player_strafeSpeedScale", 0.8 * factor);
    setdvar("player_sprintStrafeSpeedScale", 0.667 * factor);
}
onPlayerSpawned()
{
    self endon( "disconnect" );
    for(;;)
    {
        self waittill( "spawned_player" );
        self.real_streak = 0;
        self.nuke_milestone = 1;
        self thread createMiniMapCounter();
        self thread monitorNukeActivation();
    }
}
Callback_PlayerKilled_NukeMonitor( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
    if ( isDefined( attacker ) && isPlayer( attacker ) && attacker != self )
    {
        if ( isAllowedKill( sMeansOfDeath, sWeapon ) )
        {
            attacker.real_streak++;
            attacker notify( "update_nuke_streak" );
        }
    }
    if ( isDefined( level.prevCallbackPlayerKilled ) )
    {
        self [[level.prevCallbackPlayerKilled]]( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );
    }
}
isAllowedKill( sMeansOfDeath, sWeapon )
{
    switch( sMeansOfDeath )
    {
        case "MOD_PISTOL_BULLET":
        case "MOD_RIFLE_BULLET":
        case "MOD_HEAD_SHOT":
        case "MOD_MELEE":
            return true;
    }
    if ( !isDefined( sWeapon ) ) return false;
    if ( sWeapon == "frag_grenade_mp" || sWeapon == "semtex_mp" || sWeapon == "c4_mp" || sWeapon == "claymore_mp" || sWeapon == "rpg_mp" || sWeapon == "at4_mp" || sWeapon == "throwingknife_mp" )
        return true;
    return false;
}
monitorNukeEarning()
{
    self endon( "disconnect" );
    for(;;)
    {
        self waittill( "update_nuke_streak" );
        if ( self.real_streak >= ( level.nuke_requirement * self.nuke_milestone ) )
        {
            self.nukes_earned++;
            self.nuke_milestone++;
            notifyData = spawnstruct();
            notifyData.titleText = "^2NUKE EARNED!";
            notifyData.notifyText = "Press ^3[{+actionslot 3}] ^7to activate";
            notifyData.glowColor = (0, 1, 0);
            notifyData.duration = 5;
            notifyData.font = "hudbig";
            self thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
            self PlaySound( "mp_level_up" );
        }
    }
}
createMiniMapCounter()
{
    self endon( "disconnect" );
    self endon( "death" );
    if ( isDefined( self.nukeStreakHUD ) ) self.nukeStreakHUD destroy();
    if ( isDefined( self.nukeReadyHUD ) ) self.nukeReadyHUD destroy();
    if ( isDefined( self.kdrHUD ) ) self.kdrHUD destroy();
    self.kdrHUD = newClientHudElem( self );
    self.kdrHUD.alignX = "left";
    self.kdrHUD.alignY = "bottom";
    self.kdrHUD.horzAlign = "left";
    self.kdrHUD.vertAlign = "bottom";
    self.kdrHUD.x = 5;
    self.kdrHUD.y = -55;
    self.kdrHUD.fontScale = 1.4;
    self.kdrHUD.font = "objective";
    self.kdrHUD.label = &"K/D: ^6";
    self.kdrHUD.alpha = 1;
    self.nukeStreakHUD = newClientHudElem( self );
    self.nukeStreakHUD.alignX = "left";
    self.nukeStreakHUD.alignY = "bottom";
    self.nukeStreakHUD.horzAlign = "left";
    self.nukeStreakHUD.vertAlign = "bottom";
    self.nukeStreakHUD.x = 5;
    self.nukeStreakHUD.y = -40;
    self.nukeStreakHUD.fontScale = 1.4;
    self.nukeStreakHUD.font = "objective";
    self.nukeStreakHUD.label = &"Streak: ^2";
    self.nukeStreakHUD.alpha = 1;
    self.nukeReadyHUD = newClientHudElem( self );
    self.nukeReadyHUD.alignX = "left";
    self.nukeReadyHUD.alignY = "top";
    self.nukeReadyHUD.horzAlign = "left";
    self.nukeReadyHUD.vertAlign = "top";
    self.nukeReadyHUD.x = 10;
    self.nukeReadyHUD.y = 110;
    self.nukeReadyHUD.fontScale = 1.2;
    self.nukeReadyHUD.font = "objective";
    self.nukeReadyHUD.alpha = 0;
    last_count = -1;
    last_cooldown = -1;
    for(;;)
    {
        deaths = self.deaths;
        if(deaths == 0) deaths = 1;
        ratio = self.kills / deaths;
        self.kdrHUD setValue( ratio );
        self.nukeStreakHUD setValue( self.real_streak );
        available = self.nukes_earned - self.nukes_used;
        if ( available > 0 )
        {
            self.nukeReadyHUD.alpha = 1;
            if(level.nuke_cooldown_timer > 0)
            {
                if(last_cooldown != level.nuke_cooldown_timer)
                {
                    self.nukeReadyHUD setText("");
                    self.nukeReadyHUD.label = &"^1COOLDOWN: ^7";
                    self.nukeReadyHUD setValue(level.nuke_cooldown_timer);
                    last_cooldown = level.nuke_cooldown_timer;
                    last_count = -1;
                }
            }
            else
            {
                if(last_count != available)
                {
                    self.nukeReadyHUD.label = &"";
                    self.nukeReadyHUD setText( "^7[x^3" + available + "^7] ^6NUKE READY! ^7Press ^3[{+actionslot 3}] ^7to activate" );
                    last_count = available;
                    last_cooldown = -1;
                }
            }
        }
        else self.nukeReadyHUD.alpha = 0;
        wait 0.1;
    }
}
monitorNukeActivation()
{
    self endon( "disconnect" );
    self endon( "death" );
    self notifyonplayercommand( "nuke_pressed", "+actionslot 3" );
    for(;;)
    {
        self waittill( "nuke_pressed" );
        available = self.nukes_earned - self.nukes_used;
        if ( available > 0 )
        {
            if ( level.nuke_cooldown_timer > 0 )
            {
                self iPrintlnBold( "^1Nuke Cooling Down!" );
                continue;
            }
            self.nukes_used++;
            level thread executeNuke( self );
        }
    }
}
executeNuke( nuke_owner )
{
    level.nuke_in_progress = true;
    owner_team = nuke_owner.team;
    owner_name = nuke_owner.name;
    owner_color = "^8";
    if ( owner_team == "axis" ) owner_color = "^9";
    level thread nukeCooldownLogic(20);
    nuke_owner thread sendNukeWebhook();
    notifyData = spawnstruct();
    notifyData.titleText = "^1TACTICAL NUKE INCOMING!";
    notifyData.notifyText = "^7Called in by " + owner_color + owner_name;
    notifyData.glowColor = (1, 0, 0);
    notifyData.duration = 8;
    foreach( player in level.players )
    {
        player PlaySound( "mp_tactical_nuke" );
        player PlaySound( "mpl_killstreak_nuke" );
        player thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
    }
    level.nukeTimer = createServerFontString( "objective", 2.5 );
    level.nukeTimer setPoint( "TOP", "TOP", 0, 50 );
    level.nukeTimer.color = ( 1, 0.2, 0.2 );
    level.nukeTimer.glowAlpha = 1;
    level.nukeTimer.glowColor = ( 1, 0, 0 );
    timer = 10;
    while ( timer > 0 )
    {
        level.nukeTimer.label = &"^1DETONATION IN: ^7";
        level.nukeTimer setValue( timer );
        foreach( player in level.players ) player PlaySound( "ui_mp_nukebomb_timer" );
        if(timer <= 3) {
            wait 0.5;
            foreach( player in level.players ) player PlaySound( "ui_mp_nukebomb_timer" );
            wait 0.5;
        }
        else wait 1;
        timer--;
    }
    level.nukeTimer destroy();
    setSlowMotion( 1.0, 0.25, 0.5 );
    wait 0.5;
    VisionSetNaked( "mp_nuke_aftermath", 0.5 );
    foreach( player in level.players )
    {
        player PlaySound( "nuke_explosion" );
        player PlaySound( "exp_suitcase_bomb_main" );
        player PlaySound( "wpn_emp_terminal_hit" );
        player thread nukePhysicalEffects();
        player thread applyNukeEMP();
    }
    wait 0.2;
    current_owner_team = "none";
    if(isDefined(nuke_owner)) current_owner_team = nuke_owner.team;
    foreach( player in level.players )
    {
        if ( !isDefined( player ) ) continue;
        p_name = player.name;
        p_team = player.team;
        if ( !isAlive(player) || p_team == current_owner_team ) continue;
        victim_color = "^8";
        if ( p_team == "axis" ) victim_color = "^9";
        player dodamage(player.health + 1000, player.origin, nuke_owner, nuke_owner, "body", "MOD_EXPLOSIVE", 0, "killstreak_nuke_mp");
        foreach( p in level.players )
        {
            p iprintln(owner_color + owner_name + " ^2Nuked " + victim_color + p_name);
        }
    }
    wait 0.5;
    setSlowMotion( 0.25, 1.0, 0.5 );
    wait 15;
    VisionSetNaked( getDvar("mapname"), 10 );
    level.nuke_in_progress = false;
}
applyNukeEMP()
{
    self endon("disconnect");
    self setempjammed( true );
    playFX( level._effect["emp_flash"], self.origin );
    wait 10;
    if(isDefined(self)) self setempjammed( false );
}
sendNukeWebhook()
{
    if(!isDefined(self)) return;
    headers = [];
    headers["Content-Type"] = "application/json";
    embed = [];
    embed["title"] = "☢️ TACTICAL NUKE INBOUND";
    embed["description"] = "A player has achieved the ultimate killstreak!";
    embed["color"] = 15158528;
    field_player = [];
    field_player["name"] = "Player";
    field_player["value"] = self.name;
    field_player["inline"] = true;
    embed["fields"] = [];
    embed["fields"][0] = field_player;
    data = [];
    data["embeds"] = [];
    data["embeds"][0] = embed;
    data["username"] = "☢️ TACTICAL NUKE INBOUND";
    data["avatar_url"] = "https://static.wikia.nocookie.net/callofduty/images/a/a9/Tactical_Nuke_inventory_icon_MW2.gif/revision/latest?cb=20121220062935";
    req = httpPost("https://discord.com/api/webhooks/REDACTED", jsonSerialize(data, 0), headers);
    req waittill("done", result);
}
nukeCooldownLogic(duration)
{
    level.nuke_cooldown_timer = duration;
    while(level.nuke_cooldown_timer > 0)
    {
        wait 1;
        level.nuke_cooldown_timer--;
    }
}
nukePhysicalEffects()
{
    self endon("disconnect");
    earthquake( 0.8, 6, self.origin, 100000 );
    self shellshock( "frag_grenade_mp", 7 );
    self PlaySound("p_ui_whiz_by");
    self PlaySound("wpn_emp_bomb");
}
nukeFlash()
{
    self endon( "disconnect" );
    if( isDefined( self.nuke_overlay ) ) self.nuke_overlay destroy();
    self.nuke_overlay = newClientHudElem( self );
    self.nuke_overlay.horzAlign = "fullscreen";
    self.nuke_overlay.vertAlign = "fullscreen";
    self.nuke_overlay setShader( "white", 640, 480 );
    self.nuke_overlay.alpha = 0;
    self.nuke_overlay.sort = 100;
    self.nuke_overlay fadeOverTime( 0.1 );
    self.nuke_overlay.alpha = 1;
    wait 3;
    self.nuke_overlay fadeOverTime( 6 );
    self.nuke_overlay.alpha = 0;
    wait 6;
    if(isDefined(self.nuke_overlay)) self.nuke_overlay destroy();
}
displayWelcomeMessage()
{
    self endon( "disconnect" );
    welcome_data = spawnstruct();
    welcome_data.titleText = "^6Welcome ^2" + self.name + "^6!";
    welcome_data.notifyText = "^2G^6L ^2H^6F^2!";
    welcome_data.duration = 6;
    welcome_data.font = "hudbig";
    maps\mp\gametypes\_hud_message::notifyMessage( welcome_data );
}