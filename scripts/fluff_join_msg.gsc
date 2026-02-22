init()
{
    level thread onPlayerConnect();
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
    // Only show the message on the very first spawn of the match
    if(!isDefined(self.firstSpawnDone))
    {
        self.firstSpawnDone = true;
        // Wait a few seconds after spawning so the UI is clear
        wait 5;
        self iprintln("^6Have Suggestions or Feedback?");
        self iprintln("^2Want to see Nukes Or Zombies Leaderboards?");
        self iprintln("^6Visit ^2https://nfld99.com/Bo2");
    }
}