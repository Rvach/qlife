/*
	weapons.qc

	weapon and weapon hit functions

	Copyright (C) 1996-1997  Id Software, Inc.

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA

*/
// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");  // new rocket explosion
	precache_sound ("weapons/rocket1i.wav");        // spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav"); // player shotgun
	precache_sound ("weapons/ric1.wav");    // ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");    // ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");    // ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");  // super spikes
	precache_sound ("weapons/tink1.wav");   // spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav"); // grenade launcher
	precache_sound ("weapons/bounce.wav");          // grenade bounce
	precache_sound ("weapons/shotgn2.wav"); // super shotgun

    precache_sound ("misc/basekey.wav");    // Laser Trip Bomb activate sound
    precache_sound ("sounds/weapons/deploy.wav");  // Laser Trip Bomb weapon sound
    precache_model ("progs/WORLD/world_tripmine.md2");         // Laser Trip Bomb model

	precache_model("progs/laser.MDL"); // Laser for gauss
	precache_sound("sounds/weapons/tau_cannon_fire.wav"); 		// Laser for gauss
	precache_sound("sounds/weapons/tau_cannon_charging.wav"); 	// Laser for gauss
	precache_sound("sounds/weapons/bow_fire_arrow.wav"); 		// Laser for crossbow
	precache_sound("sounds/weapons/blaster.wav"); 				// Blaster
	precache_sound("sounds/weapons/blaster_super.wav"); 		// Super Blaster

	precache_model("progs/w_blaster.md2");
	precache_model("progs/w_blaster_super.md2");
	precache_model("progs/w_shotgun.md2");
    precache_model("progs/w_autogun.md2"); 	// auto firer model
    precache_model("progs/w_rocket.md2"); 	// rpg model
	precache_model("progs/w_link.md2"); 	// link model
    precache_model("progs/w_gauss.md2"); 	// gauss model
	precache_model("progs/w_crossbow.md2"); // crossbow model
    precache_model("progs/w_tripmine.md2"); // tripmine model
}

void()	x_explode1	=	[0,	x_explode2] {};
void()	x_explode2	=	[1,	x_explode3] {};
void()	x_explode3	=	[2,	x_explode4] {};
void()	x_explode4	=	[3,	x_explode5] {};
void()	x_explode5	=	[4,	x_explode6] {};
void()	x_explode6	=	[5,	x_explode7] {};
void()	x_explode7	=	[6,	x_explode8] {};
void()	x_explode8	=	[7,	x_explode9] {};
void()	x_explode9	=	[8,	x_explode10] {};
void()	x_explode10	=	[9,	x_explode11] {};
void()	x_explode11	=	[10,	x_explode12] {};
void()	x_explode12	=	[11,	x_explode13] {};
void()	x_explode13	=	[12,	x_explode14] {};
void()	x_explode14	=	[13,	x_explode15] {};
void()	x_explode15	=	[14,	SUB_Remove] {};

void()	smokepuff1	=	[0,	smokepuff2] {};
void()	smokepuff2	=	[1,	smokepuff3] {};
void()	smokepuff3	=	[2,	smokepuff4] {};
void()	smokepuff4	=	[3,	smokepuff5] {};
void()	smokepuff5	=	[4,	smokepuff6] {};
void()	smokepuff6	=	[5,	smokepuff7] {};
void()	smokepuff7	=	[6,	smokepuff8] {};
void()	smokepuff8	=	[7,	smokepuff9] {};
void()	smokepuff9	=	[8,	smokepuff10] {};
void()	smokepuff10	=	[9,	smokepuff11] {};
void()	smokepuff11	=	[10,	smokepuff12] {};
void()	smokepuff12	=	[11,	smokepuff13] {};
void()	smokepuff13	=	[12,	smokepuff14] {};
void()	smokepuff14	=	[13,	smokepuff15] {};
void()	smokepuff15	=	[14,	smokepuff16] {};
void()	smokepuff16	=	[15,	smokepuff17] {};
void()	smokepuff17	=	[16,	smokepuff18] {};
void()	smokepuff18	=	[17,	smokepuff19] {};
void()	smokepuff19	=	[18,	SUB_Remove] {};

#define crandom() (2*(random()-0.5))

void (entity targ, entity inflictor, entity attacker, float damage, INTEGER mod) T_Damage;
void () player_anim_run;
void ()  kkelad_anim_crouch;
void(entity inflictor, entity attacker, float damage, float radius, entity ignore, INTEGER mod) T_RadiusDamage;
void(vector org, float damage) SpawnBlood;
void() SuperDamageSound;

/*
Ammo update functions
*/
void(entity ent) W_UpdateAmmoCounts =
{
	// update current ammo
	switch (ent.ammo_type)
	{
        case AT_BLASTER:
            ent.currentammo = ent.ammo_blaster_real;
            break;
        case AT_SUPER_BLASTER:
            ent.currentammo = ent.ammo_blaster_super_real;
            break;
        case AT_SHOTGUN:
            ent.currentammo = ent.ammo_shotgun_real;
            break;
        case AT_AUTOGUN:
            ent.currentammo = ent.ammo_autogun_real;
            break;
        case AT_AUTOGUN_GRENADE:
            ent.currentammo = ent.ammo_autogun_grenades_real;
            break;
         case AT_RPG:
            ent.currentammo = ent.ammo_rpg_real;
            break;
         case AT_CELLS:
            ent.currentammo = ent.ammo_cells_real;
            break;
         case AT_CROSSBOW:
            ent.currentammo = ent.ammo_cross_bow_real;
            break;
         case AT_TRIPMINE:
            ent.currentammo = ent.ammo_tripmines_real;
            break;
        default:
            ent.currentammo = 0;
	}
	
	// update ammo display (FTE progs converts to floats here)
	ent.ammo_blaster            = ent.ammo_blaster_real;
	ent.ammo_blaster_super      = ent.ammo_blaster_super_real;
	ent.ammo_shotgun            = ent.ammo_shotgun_real;
	ent.ammo_autogun            = ent.ammo_autogun_real;
	ent.ammo_autogun_grenades   = ent.ammo_autogun_grenades_real;
	ent.ammo_rpg                = ent.ammo_rpg_real;
	ent.ammo_cells              = ent.ammo_cells_real;
    ent.ammo_cross_bow           = ent.ammo_cross_bow_real;
    ent.ammo_tripmines          = ent.ammo_tripmines_real;

};

void() Zoom_Reset = 
{
    self.zooming = WM_UNINIT;
    // Restore Default FOV // TO DO : Find out how to properly save default zoom
    stuffcmd(self, "fov 100\n");
    // stuffcmd(self, "fov ");
    // stuffcmd(self, ftos(self.zoom_off_fov));
    // stuffcmd(self, "\n");
}

void() Zoom_Toggle = 
{
	if (self.weapon == W_CROSSBOW || self.weapon == W_SUPER_BLASTER)
	{
		if (self.zooming == WM_UNINIT)          // Enable Zoom
		{
            self.zoom_off_fov = cvar("fov");
            self.zooming = WEAPON_SHOTGUN;
			stuffcmd(self, "fov 30\n");
		}
		else if (self.zooming == WEAPON_SHOTGUN) // Disable Zoom
		{
            Zoom_Reset();
		}
	}
	else
	{
        Zoom_Reset();
	}
};


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/
// different from W_CheckNoAmmo due to SSG/SNG being able to fire 1 shot instead of 2...
float(float wep) W_HasAmmo =
{
	switch (wep)
	{
		case W_BLASTER:
			return self.ammo_blaster_real >= 1;
		case W_SUPER_BLASTER:
			return self.ammo_blaster_super_real >= 1;
		case W_SHOTGUN:
			return self.ammo_shotgun_real >= 2;
		case W_AUTOGUN:
			return self.ammo_autogun_real >= 1;
		case W_RPG:
			return self.ammo_rpg_real >= 2;
		case W_LINK:
            return self.ammo_cells_real >= 1;
		case W_GAUSS:
			return self.ammo_cells_real >= 1 || self.charging_weapon > 0;;
		case W_CROSSBOW:
			return self.ammo_cross_bow_real >= 1;
		case W_TRIPMINE:
			return self.ammo_tripmines_real >= 1;
	}

	return TRUE;
};

void() W_UpdateWeapon =
{
	player_anim_run ();              // get out of any weapon firing states
    Zoom_Reset();              // reset zoom

	self.items = self.items - ( self.items & (IT_AMMO_BLASTER | IT_AMMO_SUPER_BLASTER | IT_AMMO_SHOTGUN | IT_AMMO_AUTOGUN | IT_AMMO_RPG | IT_AMMO_CELLS | IT_AMMO_CROSS_BOW | IT_AMMO_TRIPMINES) );
    self.weaponframe = 0;
	switch (self.weapon)
	{
		case W_BLASTER:
			// self.weaponmodel = "progs/v_axe.mdl";
			// self.ammo_type = AT_NONE;
			//         self.weaponframe = 7;
			self.weaponmodel = "progs/w_blaster.md2";
			self.items = self.items | IT_AMMO_BLASTER;
			self.ammo_type = AT_BLASTER;
			// self.weaponframe = 124;
			break;
		case W_SUPER_BLASTER:
			self.weaponmodel = "progs/w_blaster_super.md2";
			self.items = self.items | IT_AMMO_SUPER_BLASTER;
			self.ammo_type = AT_SUPER_BLASTER;
			// self.weaponframe = 124;
			break;
		case W_SHOTGUN:
			self.weaponmodel = "progs/w_shotgun.md2";
			self.items = self.items | IT_AMMO_SHOTGUN;
			self.ammo_type = AT_SHOTGUN;
			break;
		case W_AUTOGUN:
			//self.weaponmodel = "progs/v_nail.MDL";
            self.weaponmodel = "progs/w_autogun.md2";
			self.items = self.items | IT_AMMO_AUTOGUN;
			self.ammo_type = AT_AUTOGUN;
			break;
		case W_RPG:
			//self.weaponmodel = "progs/v_rpg.mdl";
            self.weaponmodel = "progs/w_rocket.md2";
			self.items = self.items | IT_AMMO_RPG;
			self.ammo_type = AT_RPG;
			break;
		case W_LINK:
			//self.weaponmodel = "progs/v_egon.mdl";
			self.weaponmodel = "progs/w_link.md2";
			self.items = self.items | IT_AMMO_CELLS;
			self.ammo_type = AT_CELLS;
			break;
		case W_GAUSS:
			//self.weaponmodel = "progs/v_gauss.mdl";
            self.weaponmodel = "progs/w_gauss.md2";
			self.items = self.items | IT_AMMO_CELLS;
			self.ammo_type = AT_CELLS;
			break;
		case W_CROSSBOW:
			self.weaponmodel = "progs/w_crossbow.md2";
			self.items = self.items | IT_AMMO_CROSS_BOW;
			self.ammo_type = AT_CROSSBOW;
			break;
		case W_TRIPMINE:
			//self.weaponmodel = "progs/v_tripmine.MDL";
            self.weaponmodel = "progs/w_tripmine.md2";
			self.items = self.items | IT_AMMO_TRIPMINES;
			self.ammo_type = AT_TRIPMINE;
			break;
		default:
			self.weaponmodel = "";
	}
};

void(float weap) W_WeaponSwitch =
{
	// skip weapon model/ammo_type update if this isn't a new weapon
	if (self.weapon != weap)
	{
		self.weapon = weap;
		W_UpdateWeapon();
	}

	// always update ammo count
	W_UpdateAmmoCounts(self);
};

float() W_BestWeapon =
{
	float fl;

	if (self.waterlevel <= 1)
		fl = W_LINK;
	else
		fl = W_BLASTER;

	while (1)
	{
		if ( (self.weapons & fl) && W_HasAmmo(fl) )
			return fl;

		// best weapon order
		switch (fl)
		{
			case W_TRIPMINE:
				fl = W_GAUSS;
				break;
			case W_GAUSS:
				fl = W_LINK;
				break;
			case W_LINK:
				fl = W_CROSSBOW;
				break;
			case W_CROSSBOW:
				fl = W_RPG;
				break;
			case W_RPG:
				fl = W_AUTOGUN;
				break;
			case W_AUTOGUN:
				fl = W_SHOTGUN;
				break;
			case W_SHOTGUN:
				fl = W_SUPER_BLASTER;
				break;
			case W_SUPER_BLASTER:
			default:
				return W_BLASTER; // so we don't get an infinite loop with certain engines
		}
		//return fl;
	}
};

float() W_CheckNoAmmo =
{
	if (self.currentammo > 0)
		return TRUE;

	if (self.weapon == W_BLASTER)
		return TRUE;
	
	W_WeaponSwitch (W_BestWeapon ());
	
// drop the weapon down
	return FALSE || self.charging_weapon > 0;
};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local   float   fl;
	
	switch (self.impulse)
	{
	case 1:
		fl = W_BLASTER;
		break;
	case 2:
		fl = W_SUPER_BLASTER;
		break;
	case 3:
		fl = W_SHOTGUN;
		break;
	case 4:
		fl = W_AUTOGUN;
		break;
	case 5:
		fl = W_RPG;
		break;
	case 6:
		fl = W_LINK;
		break;
	case 7:
		fl = W_GAUSS;
		break;
	case 8:
		fl = W_CROSSBOW;
		break;
    case 9: 
        fl = W_TRIPMINE;
        break;
	}
	
	
	if (!(self.weapons & fl))
	{       // don't have the weapon or the ammo
		sprint1 (self, PRINT_HIGH, "no weapon.\n");
		return;
	}
	
	if (!W_HasAmmo(fl))
	{       // don't have the ammo
		sprint1 (self, PRINT_HIGH, "not enough ammo.\n");
		return;
	}

//
// set weapon, set ammo
//
	W_WeaponSwitch (fl);
};

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
	if (cvar("sv_cheats") != 1)
      if (deathmatch || coop)
		return;

	self.ammo_shotgun_real = 100;
	self.ammo_blaster_super_real = 200;
	self.ammo_blaster_real = 100;
	self.ammo_autogun_real = 100;
	self.weapons |= W_BLASTER |
		W_SUPER_BLASTER |
		W_SHOTGUN |
		W_AUTOGUN |
		W_RPG |
		W_LINK |
		W_GAUSS |
		W_CROSSBOW |
        W_TRIPMINE |
		IT_KEY1 | IT_KEY2;

	W_WeaponSwitch (W_GAUSS);
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local float w;
	w = self.weapon;

	while (1)
	{
		switch (w)
		{
		case W_TRIPMINE:
			w = W_BLASTER;
			break;
		case W_BLASTER:
			w = W_SUPER_BLASTER;
			break;
		case W_SUPER_BLASTER:
			w = W_SHOTGUN;
			break;
		case W_SHOTGUN:
			w = W_AUTOGUN;
			break;
		case W_AUTOGUN:
			w = W_RPG;
			break;
		case W_RPG:
			w = W_LINK;
			break;
		case W_LINK:
			w = W_GAUSS;
			break;
		case W_GAUSS:
			w = W_CROSSBOW;
			break;
		case W_CROSSBOW:
			w = W_TRIPMINE;
			break;
		}


	
		if ( (self.weapons & w) && W_HasAmmo(w) )
		{
			W_WeaponSwitch (w);
			return;
		}
	}

};


/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	local float w;
	w = self.weapon;

	while (1)
	{
		switch (w)
		{
        case W_TRIPMINE:
			w = W_CROSSBOW;
			break;
		case W_CROSSBOW:
			w = W_GAUSS;
			break;
		case W_GAUSS:
			w = W_LINK;
			break;
		case W_LINK:
			w = W_RPG;
			break;
		case W_RPG:
			w = W_AUTOGUN;
			break;
		case W_AUTOGUN:
			w = W_SHOTGUN;
			break;
		case W_SHOTGUN:
			w = W_SUPER_BLASTER;
			break;
		case W_SUPER_BLASTER:
			w = W_BLASTER;
			break;
		case W_BLASTER:
			w = W_TRIPMINE;
			break;
		}
	
		if ( (self.weapons & w) && W_HasAmmo(w) )
		{
			W_WeaponSwitch (w);
			return;
		}
	}

};


/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
      if (deathmatch || coop)
		return;

	serverflags = serverflags * 2 + 1;
};

#ifdef HALFLIFE
void (entity t_src, float prtype) FindUseEntity =
{
	local vector source;
	local entity oldself;

	
	makevectors (t_src.v_angle);
	source = t_src.origin + '0 0 16';
	traceline (source, source + v_forward*64, FALSE, t_src);
/*	makevectors (t_src.angles);
	source = (t_src.origin);
	source_z += t_src.view_ofs_z;
	traceline (source, (source + (v_forward * 64)), 1, t_src);*/
//	if ((trace_fraction == 1))
//	{
//		return;
//	}

	if (trace_ent != world && trace_ent.hl_use)
	{
		oldself = self;
		self = trace_ent;
		activator = oldself;
		self.hl_use();
		self = oldself;
	}
	if (prtype == 2)
		if (trace_ent != world && trace_ent.use)
		{
			oldself = self;
			self = trace_ent;
			activator = oldself;
			self.use();
			self = oldself;
		}	

	//if (trace_ent != world)
	//	eprint(trace_ent);
	if (prtype)
		_bprint(trace_ent.classname, " te classname, ", trace_ent.targetname, " te targetname, ", trace_ent.target, " te target\n" );
};

// find and print info of all nearby entities
void (entity t_src) FindEntities =
{
	local entity te;
	
	te = nextent(world);
	while (te != world)
	{
		if ( ( vlen(te.origin - t_src.origin) < 100 || vlen(((te.absmax+te.absmin)*.5) - t_src.origin) < 100 || vlen(((te.mins+te.maxs)*.5) - t_src.origin) < 100 ) && te != t_src) {
			_bprint("FOUND ONE!\n");
			eprint(te);
		}
		te = nextent(te); 
	}
};
#endif

/*
============
Weapon Fire Modes Section
============
*/
void() W_ToggleFireMode =
{
	if (self.secondary_attack_mode == 0)
	{
		self.secondary_attack_mode = 1; // now put it on the other trigger
		centerprint(self,"Secondary Mode\n"); // let him know without clogging the console with unsubliminal messages
		return;
	}
	if (self.secondary_attack_mode == 1)
	{
		self.secondary_attack_mode = 0; // ditto
		centerprint(self,"Primary Mode\n");
		return;
	}
};

//============================================================================

/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local   entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');            
	setorigin (missile, org);
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};

/*
void() testfunction =
{
	local vector v;
	local float a, b, c;

	a = 2;
	b = 4;
	c = 6;
	a *= 2;
	b *= 2;
	c *= 2;
	v = '2 4 6';
	v *= 2;
	if (!a && !b && !c)
		return;

	if (!v)
		return;

	v_x = 23;

	if (self.health && self.ammo_shells && self.ammo_cells)
		return;
};
*/

void(vector org) SpawnSmoke =	//Spawns a puff of smoke
{
	newmis = spawn();
	newmis.movetype = MOVETYPE_NONE;
	newmis.classname = "smoke";
	newmis.touch = SUB_Null;
	newmis.velocity = '0 0 0';  //Note that you could mess with the movetype and give it a z velocity for rising smoke..
	newmis.effects = newmis.effects | EF_ADDITIVE;
	setmodel(newmis, "progs/smokepuff.spr");
	newmis.solid = SOLID_NOT;
	setsize(newmis, '0 0 0', '0 0 0');
	setorigin(newmis, org);
	newmis.think = smokepuff1;
	newmis.nextthink = time + 0.1;
};

void () LaserThink =		//Updates the laserdot position - this should be done with velocity
{				// instead of changing the origin, but I'm tired..
	local vector org;

        makevectors(self.owner.v_angle);
	org = self.owner.origin + self.owner.view_ofs; //self.owner.origin + v_up * 18;

        traceline (org, org + v_forward * 4096, FALSE, self);	//Should be higher

	if (self.owner.weapon != W_RPG)		//Laser only works with our l'cher
		{
		self.owner.laser_active = 0;			//Tells Quake our laser is off
		remove(self);
		}

        if (trace_fraction == 1.0)
	{
		// Move sight inside player if something strange happens
        	setorigin(self, self.owner.origin + self.owner.view_ofs );
		return;
	}

	self.angles = vectoangles(v_forward);		//Make sure the sprite looks right
	setorigin(self, trace_endpos - v_forward*4);	//Also make sure it doesn't end up in a wall
	self.nextthink = time + 0.05;
};

void ()	SpawnLaser =		//Spawns a rocket guidance laser for a player
{
	local entity foo;

        self.laser_active = 1;	//Laser is active

	foo = spawn ();
	foo.owner = self;
	foo.movetype = MOVETYPE_NOCLIP;
	foo.solid = SOLID_NOT;

	setmodel (foo, "progs/laserdot.spr");
	foo.classname = "sight";
	foo.effects = foo.effects | EF_ADDITIVE;

	setorigin( foo, self.origin + self.view_ofs );

	foo.think = LaserThink;
	foo.nextthink = time + 0.05;	//Change this as you please
};
