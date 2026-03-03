init()
{
    level thread onPlayerConnect();
}
onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        if(player.guid == 1184872)
        {
            player thread handleFluffName();
        }
        else if(player.guid == 0) 
        {
            player thread waitAndAssignBotTeamTag();
        }
    }
}
waitAndAssignBotTeamTag()
{
    self endon("disconnect");
    while(!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
    {
        wait 0.5;
    }
    if(self.pers["team"] == "allies")
    {
        self setClantag("^6Fluff");
        self setName("^6" + self.name);
    }
    else if(self.pers["team"] == "axis")
    {
        self setClantag("^2Fluff");
        self setName("^2" + self.name);
    }
}
handleFluffName()
{
    self endon("disconnect");
    self setName("^6Mr^1.^2Fluff");
    self setClantag("^5Ownr");
}