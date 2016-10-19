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
void (entity targ, entity inflictor, entity attacker, float damage, INTEGER mod) T_Damage;
void () player_run;
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
	case AT_SHELLS:
		ent.currentammo = ent.ammo_shells_real;
		break;
	case AT_NAILS:
		ent.currentammo = ent.ammo_nails_real;
		break;
	case AT_ROCKETS:
		ent.currentammo = ent.ammo_rockets_real;
		break;
	case AT_CELLS:
		ent.currentammo = ent.ammo_cells_real;
		break;
	default:
		ent.currentammo = 0;
	}
	
	// update ammo display (FTE progs converts to floats here)
	ent.ammo_shells = ent.ammo_shells_real;
	ent.ammo_nails = ent.ammo_nails_real;
	ent.ammo_rockets = ent.ammo_rockets_real;
	ent.ammo_cells = ent.ammo_cells_real;
};





/*



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
	case IT_SHOTGUN:
		return self.ammo_shells_real >= 1;
	case IT_SUPER_SHOTGUN:
		return self.ammo_shells_real >= 2;
	case IT_NAILGUN:
		return self.ammo_nails_real >= 1;
	case IT_SUPER_NAILGUN:
		return self.ammo_nails_real >= 2;
	case IT_GRENADE_LAUNCHER:
	case IT_ROCKET_LAUNCHER:
		return self.ammo_rockets_real >= 1;
	case IT_LIGHTNING:
		return self.ammo_cells_real >= 1;
	case IT_EXTRA_WEAPON:
		return self.ammo_cells_real >= 1;
	}

	return TRUE;
};

void() W_UpdateWeapon =
{
	player_run ();          // get out of any weapon firing states

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
    self.weaponframe = 0;
	switch (self.weapon)
	{
	case IT_AXE:
		self.weaponmodel = "progs/v_axe.mdl";
		self.ammo_type = AT_NONE;
                self.weaponframe = 7;
		break;
	case IT_SHOTGUN:
		self.weaponmodel = "progs/v_9mm.MDL";
		self.items = self.items | IT_SHELLS;
		self.ammo_type = AT_SHELLS;
        self.weaponframe = 124;
		break;
	case IT_SUPER_SHOTGUN:
		self.weaponmodel = "progs/v_shot2.mdl";
		self.items = self.items | IT_SHELLS;
		self.ammo_type = AT_SHELLS;
		break;
	case IT_NAILGUN:
		self.weaponmodel = "progs/v_tripmine.MDL";
		self.items = self.items | IT_NAILS;
		self.ammo_type = AT_NAILS;
		break;
	case IT_SUPER_NAILGUN:
		self.weaponmodel = "progs/v_nail.MDL";
		self.items = self.items | IT_NAILS;
		self.ammo_type = AT_NAILS;
		break;
	case IT_GRENADE_LAUNCHER:
		self.weaponmodel = "progs/v_nail.MDL";
		self.items = self.items | IT_ROCKETS;
		self.ammo_type = AT_ROCKETS;
		break;
	case IT_ROCKET_LAUNCHER:
		self.weaponmodel = "progs/v_rpg.mdl";
		self.items = self.items | IT_ROCKETS;
		self.ammo_type = AT_ROCKETS;
		break;
	case IT_LIGHTNING:
		self.weaponmodel = "progs/v_egon.mdl";
		self.items = self.items | IT_CELLS;
		self.ammo_type = AT_CELLS;
		break;
	case IT_EXTRA_WEAPON:
		self.weaponmodel = "progs/v_nail2.mdl";
		self.items = self.items | IT_CELLS;
		self.ammo_type = AT_CELLS;
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
		fl = IT_LIGHTNING;
	else
		fl = IT_SUPER_NAILGUN;

	while (1)
	{
		if ( (self.items & fl) && W_HasAmmo(fl) )
			return fl;

		// best weapon order
		switch (fl)
		{
        case IT_EXTRA_WEAPON:
			fl = IT_LIGHTNING;
			break;
		case IT_LIGHTNING:
			fl = IT_SUPER_NAILGUN;
			break;
		case IT_SUPER_NAILGUN:
			fl = IT_SUPER_SHOTGUN;
			break;
		case IT_SUPER_SHOTGUN:
			fl = IT_NAILGUN;
			break;
		case IT_NAILGUN:
			fl = IT_SHOTGUN;
			break;
		case IT_SHOTGUN:
		default:
			return IT_AXE; // so we don't get an infinite loop with certain engines
		}
	}
};

float() W_CheckNoAmmo =
{
	if (self.currentammo > 0)
		return TRUE;

	if (self.weapon == IT_AXE)
		return TRUE;
	
	W_WeaponSwitch (W_BestWeapon ());
	
// drop the weapon down
	return FALSE;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;
void()	player_shot1;
void()	player_nail1;
void()	player_nail2;
void()	player_light1;
void()	player_light2;
void()	player_rocket1;
void()	muzzleflash;

void() W_Attack =
{
	float r;

	if (!W_CheckNoAmmo ())
		return;

	makevectors (self.v_angle);                 // calculate forward angle for velocity
	self.show_hostile = time + 1;   // wake monsters up

	if (self.weaponstate == WS_IDLE) // start delay
		self.delay = time + 0.1;

	// animations are dealt with here
	switch (self.weapon) 
	{
	case IT_AXE:
		r = random();
		// if (r < 0.25)
		// {
		// 	self.weaponframe = 1;
		// 	player_axe1 ();
		// }
		// else if (r < 0.5)
		// {
		// 	self.weaponframe = 5;
		// 	player_axeb1 ();
		// }
		// else if (r < 0.75)
		// {
		// 	self.weaponframe = 1;
		// 	player_axec1 ();
		// }
		// else
		// {
		// 	self.weaponframe = 5;
		// 	player_axed1 ();
		// }
		self.weaponframe_time = time + 0.1;
		self.weaponframe = self.weaponframe + 1;
        if (self.weaponframe > 28)
			self.weaponframe = 19;
        else 
            self.weaponframe = 19;
		break;
    case IT_SHOTGUN:
		self.weaponframe_time = time + 0.1;
		self.weaponframe = self.weaponframe + 3;
        if (self.weaponframe > 66)
			self.weaponframe = 56;
        else 
            self.weaponframe = 56;
		break;
	case IT_NAILGUN:
	case IT_SUPER_NAILGUN:
		muzzleflash(); 
		if (self.weaponframe == 0)
			self.weaponframe = 0; // TO REDO temporarily off anim

		if (self.weaponframe & 1)
			player_nail1();
		else
			player_nail2();
		break;		
	case IT_GRENADE_LAUNCHER:
		self.weaponframe = 0;
		muzzleflash();
		player_rocket1();
		break;
	case IT_ROCKET_LAUNCHER:
		self.weaponframe = 1;
		muzzleflash();
		player_rocket1();
		break;
	case IT_LIGHTNING:
		muzzleflash();
		if (self.weaponframe == 0)
		{
			sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
			self.weaponframe = 1;
		}

		if (self.weaponframe & 1)
			player_light1();
		else
			player_light2();
		break;
	default:
		muzzleflash();
		self.weaponframe = 1;
		player_shot1();
	}

	SuperDamageSound();

	// firing is done here (r is used for round time instead of a temp here)
	switch (self.weapon)
	{
	case IT_AXE:
		// frame handles most of this so skip most of it
		sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
        W_FireAxe();
		r = 0.5;
		break;
	case IT_SHOTGUN:
		W_FireShotgun ();
		r = 0.4;
		break;
	case IT_SUPER_SHOTGUN:
		W_FireSuperShotgun ();
		r = 0.7;
		break;
	case IT_NAILGUN:
        player_rocket1();
        W_FireLTB();    // Our deploy function
		r = 0.8; // Wait a little
		break;
	case IT_SUPER_NAILGUN:
		W_FireSuperSpikes();
		r = 0.1;
		break;
	case IT_GRENADE_LAUNCHER:
		W_FireGrenade();
		r = 0.6;
		break;
	case IT_ROCKET_LAUNCHER:
		W_FireRocket();
		r = 0.8;
		break;
	case IT_LIGHTNING:
		W_FireLightning();
		r = 0.1;
		break;
    case IT_EXTRA_WEAPON:
		W_FireGaussSecondary(WEAPON_SPIKES);
		//W_FireGaussV2Secondary(WEAPON_SPIKES);
		r = 0.8;
		break;
	}


	if (self.weaponstate == WS_IDLE)
		self.weaponstate = WS_FIRING1;

	// advance attack time
	if (self.attack_finished <= time)
		self.attack_finished = self.attack_finished + r;
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
		fl = IT_AXE;
		break;
	case 2:
		fl = IT_SHOTGUN;
		break;
	case 3:
		fl = IT_SUPER_SHOTGUN;
		break;
	case 4:
		fl = IT_NAILGUN;
		break;
	case 5:
		fl = IT_SUPER_NAILGUN;
		break;
	case 6:
		fl = IT_GRENADE_LAUNCHER;
		break;
	case 7:
		fl = IT_ROCKET_LAUNCHER;
		break;
	case 8:
		fl = IT_LIGHTNING;
		break;
    case 9: 
        fl = IT_EXTRA_WEAPON;
        break;
	}
	
	
	if (!(self.items & fl))
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

	self.ammo_rockets_real = 100;
	self.ammo_nails_real = 200;
	self.ammo_shells_real = 100;
	self.ammo_cells_real = 100;
	self.items |= IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_LIGHTNING |
        IT_EXTRA_WEAPON |
		IT_KEY1 | IT_KEY2;

	W_WeaponSwitch (IT_ROCKET_LAUNCHER);
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
		case IT_EXTRA_WEAPON:
			w = IT_AXE;
			break;
		case IT_AXE:
			w = IT_SHOTGUN;
			break;
		case IT_SHOTGUN:
			w = IT_SUPER_SHOTGUN;
			break;
		case IT_SUPER_SHOTGUN:
			w = IT_NAILGUN;
			break;
		case IT_NAILGUN:
			w = IT_SUPER_NAILGUN;
			break;
		case IT_SUPER_NAILGUN:
			w = IT_GRENADE_LAUNCHER;
			break;
		case IT_GRENADE_LAUNCHER:
			w = IT_ROCKET_LAUNCHER;
			break;
		case IT_ROCKET_LAUNCHER:
			w = IT_LIGHTNING;
			break;
		case IT_LIGHTNING:
			w = IT_EXTRA_WEAPON;
			break;
		}


	
		if ( (self.items & w) && W_HasAmmo(w) )
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
        case IT_EXTRA_WEAPON:
			w = IT_LIGHTNING;
			break;
		case IT_LIGHTNING:
			w = IT_ROCKET_LAUNCHER;
			break;
		case IT_ROCKET_LAUNCHER:
			w = IT_GRENADE_LAUNCHER;
			break;
		case IT_GRENADE_LAUNCHER:
			w = IT_SUPER_NAILGUN;
			break;
		case IT_SUPER_NAILGUN:
			w = IT_NAILGUN;
			break;
		case IT_NAILGUN:
			w = IT_SUPER_SHOTGUN;
			break;
		case IT_SUPER_SHOTGUN:
			w = IT_SHOTGUN;
			break;
		case IT_SHOTGUN:
			w = IT_AXE;
			break;
		case IT_AXE:
			w = IT_EXTRA_WEAPON;
			break;
		}
	
		if ( (self.items & w) && W_HasAmmo(w) )
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
ImpulseCommands

============
*/
void () parse_hl_crap;
void (float do_mats, string s1, string s2) parse_hl_map;
void (string s1, string s2, string s3) hl_swap_ents;
void () hl_batch_convert;
void() ImpulseCommands =
{
	local entity test;
	local string mname;
	mname = "c1a4b";
	
	switch (self.impulse) {
	case 1 .. 9:
		W_ChangeWeapon ();
		break;
	case 10:
		CheatCommand ();
		break;
	case 11:
		CycleWeaponCommand ();
		break;
	case 12:
		ServerflagsCommand ();
		break;
	case 13:
		CycleWeaponReverseCommand ();
		break;
#ifdef HALFLIFE
	case 102:
        if(self.crouchflags != #CROUCH_ON) {
            setsize(self, VEC_HULL_MIN, '16 16 18');
            self.crouchflags = #CROUCH_ON;
            self.view_ofs_z = 18;  
        } else {
            self.crouchflags = #CROUCH_TRYSTAND;
        }
		break;
	case 103:
		self.crouchflags = #CROUCH_TRYSTAND;
		break;
	case 104:
		FindUseEntity(self, 0);
		break;
	case 105:
		FindEntities(self);
		break;
	case 106:
		_bprint(vtos(self.origin), "\n");
		break;
	case 107:
		FindUseEntity(self, 1);
		break;
	case 109:
		parse_hl_crap();
		break;
	case 110:
		test = find(world, classname, "trigger_once");
		while (test)
		{
			if (test.target == "retinalscan") {
				//_bprint("I EXIST at", vtos(self.origin), "\n");
				setorigin(self, (test.absmax+test.absmin)*.5);
			}
			test = find(test, classname, "trigger_once");
		}
		break;
	case 120:
		FindUseEntity(self, 2);
		break;
	case 121:
		parse_hl_map(1, mname, mname);
		break;
	case 122:
		hl_swap_ents(mname,mname,mname);
		break;
	case 123:
		_bprint(" no mats being parsed\n");
		parse_hl_map(0, "toconv", "toconv");
		break;
	case 124:
		hl_batch_convert();
		break;
#endif
	}

	self.impulse = 0;
};

/*
============
W_HandlePlayerFrame

Handle player weapon model
============
*/
void() W_HandlePlayerFrame =
{
	if (!self.weaponframe)
		return;

	if (self.weaponframe_time >= time)
		return;

	switch (self.weapon)
	{
	case IT_AXE:
		// axe frames can start at 1 or 5
		self.weaponframe_time = time + 0.1;
		self.weaponframe = self.weaponframe + 1;
		if (self.weaponframe > 12)
			self.weaponframe = 8;
		return;
    case IT_SHOTGUN:
		self.weaponframe_time = time + 0.1;
		self.weaponframe = self.weaponframe + 1;
        if (self.weaponframe > 73)
			self.weaponframe = 63;
        else 
            self.weaponframe = 63;
		return;
	case IT_NAILGUN:
	case IT_SUPER_NAILGUN:
		// cycle until fire button is released
		if (self.weaponstate != WS_IDLE)
 		{
			self.weaponframe_time = time + 0.1;
  			self.weaponframe = self.weaponframe + 1;
  			if (self.weaponframe > 8)
  				self.weaponframe = 1;
  		}
  		else
  			self.weaponframe = 0;

		return;
	case IT_LIGHTNING:
		// cycle until fire button is released
		if (self.weaponstate != WS_IDLE)
		{
			self.weaponframe_time = time + 0.1;
			self.weaponframe = self.weaponframe + 1;
			if (self.weaponframe > 4)
				self.weaponframe = 1;
		}
		else
			self.weaponframe = 0;
		return;
	default:
		self.weaponframe = self.weaponframe + 1;
		self.weaponframe_time = time + 0.1;
		if (self.weaponframe > 6)
			self.weaponframe = 0;
	}
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	local INTEGER scount;

	W_HandlePlayerFrame();

	if (time < self.attack_finished)
		return;

	if (self.impulse)
		ImpulseCommands ();
	
// check for attack
	if (self.button0)
	{
		scount = 0;
		// play catchup but don't allow more than 4 shots per frame
		while (self.attack_finished <= time)
		{
			if (scount >= 4)
			{
				self.attack_finished = time;
				break;
			}

			W_Attack();
			scount++;
		}
	}
	else
	{
		self.attack_finished = time;
		self.weaponstate = WS_IDLE;
	}
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
