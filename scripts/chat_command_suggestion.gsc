#include scripts\chat_commands;
Init()
{
    CreateCommand(level.chat_commands["ports"], "suggest", "function", ::SuggestionCommand, 1);
    CreateCommand(level.chat_commands["ports"], "s", "function", ::SuggestionCommand, 1);
    CreateCommand(level.chat_commands["ports"], "suggestion", "function", ::SuggestionCommand, 1);
}
/* Command section */
SuggestionCommand(args)
{
    suggestionMsg = "^6Have A Suggestion? ^2Visit 'nfld99.com/Bo2.php' ^6To Submit One!";
    self iPrintlnBold(suggestionMsg);
    self iPrintln(suggestionMsg);
    self tell(suggestionMsg);
}