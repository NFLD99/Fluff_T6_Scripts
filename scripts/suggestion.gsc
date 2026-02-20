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
    level endon("game_ended");
    self endon("disconnect");
    self waittill("spawned_player");
    self tell("^6Have A Suggestion? ^2Visit 'nfld99.com/Bo2.php' ^6To Submit One!");
}
