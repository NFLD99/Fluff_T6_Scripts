#include scripts\chat_commands;
Init()
{
    CreateCommand(level.chat_commands["ports"], "restart", "function", ::RestartMapCommand, 4);
}
RestartMapCommand(args)
{
    iPrintlnBold("^1Map Restarting...");
    wait 1;
    map_restart(false);
}