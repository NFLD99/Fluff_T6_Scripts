#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_utility;
#include scripts\chat_commands;
init()
{
    level thread onPlayerConnect();
    level thread monitorPointsShare();
    CreateCommand(level.chat_commands["ports"], "share", "function", ::cmd_give, 1);
}
onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        player thread onPlayerSpawned();
    }
}
onPlayerSpawned()
{
    self endon("disconnect");
    for(;;)
    {
        self waittill("spawned_player");
        self iPrintlnBold("^6Point Sharing Active");
        self iPrintln("^7Use ^2!share <name> <amount>");
    }
}
cmd_give(args)
{
    if(!isDefined(args) || args.size < 3)
    {
        self iPrintlnBold("^1Usage: !share <name> <amount/all>");
        return;
    }
    targetName = args[1];
    amountStr = args[2];
    targetPlayer = undefined;
    players = getPlayers();
    for(i = 0; i < players.size; i++)
    {
        if(isSubStr(toLower(players[i].name), toLower(targetName)))
        {
            targetPlayer = players[i];
            break;
        }
    }
    if(!isDefined(targetPlayer))
    {
        self iPrintlnBold("^1Player not found!");
        return;
    }
    if(targetPlayer == self)
    {
        self iPrintlnBold("^1You cannot give points to yourself.");
        return;
    }
    amount = (amountStr == "all") ? self.score : int(amountStr);
    if(amount <= 0) return;
    self sharePoints(targetPlayer, amount);
}
monitorPointsShare()
{
    for(;;)
    {
        wait 0.05;
        players = getplayers();
        for(i = 0; i < players.size; i++)
        {
            player = players[i];
            if(player ActionSlotTwoButtonPressed())
            {
                player thread quickShare(100);
                wait 0.5;
            }
            if(player ActionSlotThreeButtonPressed())
            {
                player thread quickShare(250);
                wait 0.5;
            }
            if(player ActionSlotFourButtonPressed())
            {
                player thread quickShare(500);
                wait 0.5;
            }
        }
    }
}
quickShare(amount)
{
    if(self.score < amount)
    {
        self iPrintlnBold("^1Not enough points!");
        return;
    }
    targetPlayer = getPlayerInCrosshair();
    if(!isDefined(targetPlayer))
    {
        self iPrintlnBold("^1Not looking at any player!");
        return;
    }
    self sharePoints(targetPlayer, amount);
}
sharePoints(targetPlayer, amount)
{
    if(self.score < amount)
    {
        self iPrintlnBold("^1Not enough points!");
        return;
    }
    if(!isDefined(targetPlayer) || targetPlayer.sessionstate != "playing")
    {
        self iPrintlnBold("^1Target unavailable.");
        return;
    }
    self.score -= amount;
    targetPlayer.score += amount;
    self iPrintlnBold("^2Sent " + amount + " to " + targetPlayer.name);
    targetPlayer iPrintlnBold("^2Received " + amount + " from " + self.name);
    targetPlayer playLocalSound("mp_bonus_collect");
}
getPlayerInCrosshair()
{
    players = getplayers();
    bestPlayer = undefined;
    bestDot = 0.7;
    for(i = 0; i < players.size; i++)
    {
        if(players[i] == self || players[i].sessionstate != "playing")
            continue;
        toPlayer = players[i].origin - self.origin;
        toPlayer = vectorNormalize(toPlayer);
        viewDir = anglesToForward(self getPlayerAngles());
        dot = vectorDot(toPlayer, viewDir);
        if(dot > bestDot)
        {
            if(distance(self.origin, players[i].origin) < 500)
            {
                bestPlayer = players[i];
                bestDot = dot;
            }
        }
    }
    return bestPlayer;
}