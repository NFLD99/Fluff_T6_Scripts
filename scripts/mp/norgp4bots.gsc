init()
{
 level thread onPlayerConnect();
}
onPlayerConnect()
{
 for(;;)
 {
  level waittill("connected", player);
  if(isDefined(player.pers["isBot"]) && player.pers["isBot"])
  {
   player thread onBotSpawned();
  }
 }
}
onBotSpawned()
{
 self endon("disconnect");
 for(;;)
 {
  self waittill("spawned_player");
  wait 1;
  self stripLauncherWeapons();
 }
}
stripLauncherWeapons()
{
 weapons = self getweaponslist();
 foreach(weapon in weapons)
 {
  if(isLauncher(weapon))
  {
   self takeWeapon(weapon);
   self giveWeapon("fiveseven_mp");
  }
 }
}
isLauncher(weapon)
{
 switch(weapon)
 {
  case "m32_mp":
  case "smaw_mp":
  case "fhj18_mp":
  case "usrpg_mp":
   return true;
  default:
   return false;
 }
}