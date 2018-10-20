
// Basemod replacement ent defines
#define ENT_REPLACE(f,t) void(void) f = { self.classname = #t; t(); }
#define ENT_REPLACE_FUNC(f,t,x) void(void) f = { self.classname = #t; x(); t(); }

// Replacement functions
void() health_setrotten = { self.spawnflags |= H_ROTTEN; };
void() health_setmega = { self.spawnflags |= H_MEGA; };
void() ammo_setlarge = { self.spawnflags |= WEAPON_BIG2; };

// -- Quake 3 entities
// weapons
ENT_REPLACE(weapon_gauntlet, weapon_supershotgun); // Gauntlet (not normally used)
ENT_REPLACE(weapon_machinegun, weapon_nailgun); // Machinegun (not normally used)
ENT_REPLACE(weapon_shotgun, weapon_supershotgun); // Shotgun
ENT_REPLACE(weapon_plasmagun, weapon_supernailgun); // Plasma gun
ENT_REPLACE(weapon_railgun, weapon_rocketlauncher); // Railgun
ENT_REPLACE(weapon_bfg, weapon_link_gun); // BFG
// holdables
ENT_REPLACE(holdable_medikit, item_health); // personal medikit 
ENT_REPLACE(holdable_teleporter, info_null); // personal teleporter
// armor
ENT_REPLACE(item_armor_body, item_armorInv); // 100 armor
ENT_REPLACE(item_armor_combat, item_armor2); // 50 armor
ENT_REPLACE(item_armor_shard, info_null); // +5 armor shard
// powerups
ENT_REPLACE(item_enviro, item_artifact_envirosuit); // enviro powerup
ENT_REPLACE(item_flight, item_artifact_invisibility); // flight
ENT_REPLACE(item_haste, item_artifact_super_damage); // haste
ENT_REPLACE(item_quad, item_artifact_super_damage); // quad damage
ENT_REPLACE(item_invis, item_artifact_invisibility); // invisibility
ENT_REPLACE(item_regen, item_health); // regeneration
// health
ENT_REPLACE(item_health_large, item_health); // +50 health
ENT_REPLACE_FUNC(item_health_mega, item_health, health_setmega); // +100 health (ignore max)
ENT_REPLACE_FUNC(item_health_small, item_health, health_setrotten); // +5 health (ignore max)
// ammo
ENT_REPLACE(ammo_bullets, item_ammo_autogun); // Machinegun ammo
ENT_REPLACE(ammo_grenades, item_ammo_rpg); // Grenade launcher ammo
ENT_REPLACE(ammo_lightning, item_ammo_cells); // Lightning gun ammo
ENT_REPLACE_FUNC(ammo_slugs, item_ammo_rpg, ammo_setlarge); // Railgun ammo
ENT_REPLACE_FUNC(ammo_bfg, item_ammo_cells, ammo_setlarge); // BFG ammo
// other ents
ENT_REPLACE(misc_teleporter_dest, info_teleport_destination); // teleport destination
ENT_REPLACE(target_position, info_notnull); // "target" entity
ENT_REPLACE(info_player_intermission, info_intermission); // intermission

// -- Quake 2 entities
// weapons
ENT_REPLACE(weapon_chaingun, weapon_supernailgun); // chaingun
ENT_REPLACE(weapon_hyperblaster, weapon_link_gun); // hyperblaster
// armor
ENT_REPLACE(item_armor_jacket, item_armor1);
ENT_REPLACE(item_power_screen, item_armor2); // power screen (not used often)
ENT_REPLACE(item_power_shield, item_armorInv); // power shield
 // powerups
ENT_REPLACE(item_bandolier, item_ammo_rpg, ammo_setlarge); // bandolier
ENT_REPLACE(item_breather, item_artifact_envirosuit); // underwater air breather
ENT_REPLACE(item_invulnerability, item_artifact_invulnerability); // invulnerable artifact
ENT_REPLACE(item_pack, item_ammo_rpg, ammo_setlarge); // ammo pack
ENT_REPLACE(item_silencer, item_artifact_invisibility); // weapon silencer
// health
ENT_REPLACE_FUNC(item_ancient_head, item_health, health_setmega); // ancient head (+2 max health)
ENT_REPLACE_FUNC(item_adrenaline, item_health, health_setmega); // adrenaline (+1 max health)

// -- Half-life entities
// weapons
ENT_REPLACE(weapon_357, weapon_super_blaster); // 357 magnum
ENT_REPLACE(weapon_9mmAR, weapon_supernailgun); // mp5
ENT_REPLACE(weapon_9mmhandgun, weapon_nailgun); // handgun
ENT_REPLACE(weapon_crossbow, weapon_cross_bow); // crossbow
ENT_REPLACE(weapon_crowbar, info_null); // crowbar
ENT_REPLACE(weapon_egon, weapon_link_gun); // ghostbusters gun
ENT_REPLACE(weapon_gauss, weapon_gauss_gun); // tau cannon
ENT_REPLACE(weapon_handgrenade, item_ammo_rpg); // hand grenades
ENT_REPLACE(weapon_hornetgun, item_ammo_autogun); // hornet gun
ENT_REPLACE(weapon_rpg, weapon_rocketlauncher); // rpg
ENT_REPLACE(weapon_satchel, item_ammo_rpg); // satchel charge
ENT_REPLACE(weapon_snark, item_ammo_cells); // snarks
ENT_REPLACE(weapon_tripmine, weapon_trip_mine); // tripmines
// armor
ENT_REPLACE(item_battery, item_armor1); // battery charge
// powerups
ENT_REPLACE(item_airtank, item_artifact_envirosuit); // air tank (not used often)
ENT_REPLACE(item_antidote, item_health); // antidote (not used often)
ENT_REPLACE(item_longjump, item_long_jump); // long jump module
ENT_REPLACE(item_suit, item_artifact_envirosuit); // HEV suit
#ifndef HALFLIFE
// health
ENT_REPLACE(item_healthkit, item_health); // floor health kit
#endif
// ammo
ENT_REPLACE(ammo_357, item_ammo_super_blaster); // 357 ammo
ENT_REPLACE(ammo_9mmAR, item_ammo_autogun); // mp5 clip
ENT_REPLACE(ammo_9mmbox, item_ammo_autogun, ammo_setlarge); // 9mm box
ENT_REPLACE(ammo_9mmclip, item_ammo_autogun); // 9mm clip
ENT_REPLACE(ammo_ARgrenades, item_ammo_autogun_grenades); // mp5 grenades
ENT_REPLACE(ammo_buckshot, item_ammo_shotgun); // shotgun shells
ENT_REPLACE(ammo_crossbow, item_ammo_cross_bow); // crossbow bolts
ENT_REPLACE(ammo_gaussclip, item_ammo_cells); // cells for gauss/egon
ENT_REPLACE(ammo_rpgclip, item_ammo_rpg, ammo_setlarge); // RPG ammo

// special replace
void(void() func) CheckSpawn =
{
	// these ents conflict with q1 field names
	switch (self.classname)
	{
	case "ammo_shells":
		self.classname = "item_ammo_super_blaster";
		item_ammo_super_blaster();
		break;
	case "ammo_nails":
		self.classname = "item_ammo_autogun";
		item_ammo_autogun();
		break;
	case "ammo_cells":
		self.classname = "item_ammo_cells";
		item_ammo_cells();
		break;
	default:
		if (func)
			func();
		else
		{
			dprint("Couldn't find spawn function ");
			dprint(self.classname);
			dprint("\n");
		}
	}
};