#include scripts\chat_commands;
Init()
{
    CreateCommand(level.chat_commands["ports"], "fog", "function", ::FogCommand, 4, [], array("f"));
}
/* Command section */
FogCommand(args)
{
    if (!IsDefined(level.fog_enabled))
    {
        level.fog_enabled = true;
    }
    // No arguments: Simple toggle
    if (args.size < 1)
    {
        if (level.fog_enabled)
        {
            ApplyFogToAll(0);
            TellAllPlayers(array("^5" + self.name + " ^7has ^1Disabled ^7fog"));
        }
        else
        {
            ApplyFogToAll(1);
            TellAllPlayers(array("^5" + self.name + " ^7has ^2Enabled ^7fog"));
        }
        return;
    }
    input = ToLower(args[0]);
    if (input == "off" || input == "0")
    {
        ApplyFogToAll(0);
        TellAllPlayers(array("^5" + self.name + " ^7turned fog ^1OFF"));
    }
    else if (input == "on" || input == "1")
    {
        ApplyFogToAll(1);
        TellAllPlayers(array("^5" + self.name + " ^7turned fog ^2ON"));
    }
    else
    {
        density = float(args[0]);
        ApplyFogToAll(1, density);
        TellAllPlayers(array("^5" + self.name + " ^7set fog density to ^5" + density));
    }
}
/* Logic section */
ApplyFogToAll(state, density)
{
    level.fog_enabled = (state == 1);
    if (!IsDefined(density))
    {
        density = (state == 1) ? 0.6 : 0;
    }
    foreach (player in level.players)
    {
        // setclientdvar often bypasses the "cheat" restriction because it's local to the player's render
        player setclientdvar("r_fog", state);
        player setclientdvar("r_drawfog", state);
        player setclientdvar("fog_enable", state);
        player setclientdvar("fog_global_density", density);
    }
}