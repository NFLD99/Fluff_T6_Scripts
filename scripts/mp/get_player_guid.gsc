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
        Print(player.name + " GUID: " + player.guid  + "\n\n");
    }
}
