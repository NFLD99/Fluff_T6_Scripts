Init()
{
    level thread OnPlayerConnect();
}

OnPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);

        if(player.guid == 0)
            continue;

        Print(player.name + " GUID: " + player.guid);

        player thread OnPlayerSpawned();
    }
}

OnPlayerSpawned()
{
    self endon("disconnect");

    for(;;)
    {
        self waittill("spawned_player");

        if(self.guid == 0)
            continue;

        Print(self.name + " GUID: " + self.guid);
    }
}
