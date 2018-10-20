/*
	player.qc

	player functions/definitions

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
void() bubble_bob;

/*
==============================================================================

PLAYER

==============================================================================
*/

$cd /raid/quake/id1/models/player_4
$origin 0 -6 24
$base base              
$skin skin

// //
// // running
// //
// $frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

// $frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

// //
// // standing
// //
// $frame stand1 stand2 stand3 stand4 stand5

// $frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
// $frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


// //
// // pain
// //
// $frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

// $frame pain1 pain2 pain3 pain4 pain5 pain6


// //
// // death
// //

// $frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
// $frame axdeth7 axdeth8 axdeth9

// $frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
// $frame deatha9 deatha10 deatha11

// $frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
// $frame deathb9

// $frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
// $frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

// $frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
// $frame deathd8 deathd9

// $frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
// $frame deathe8 deathe9

// //
// // attacks
// //
// $frame nailatt1 nailatt2

// $frame light1 light2

// $frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

// $frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

// $frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

// $frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

// $frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

// $frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6
/*********************
	Kkelad Animations
**********************/
$frame idle1 idle2 idle3 idle4 idle5 idle6 idle7 idle8 idle9 idle10 idle11
$frame jump1 jump2 jump3 jump4 jump5 jump6 jump7 jump8 jump9 jump10 jump11
$frame crouch1 crouch2 crouch3 crouch4 crouch5 crouch6 crouch7 crouch8 crouch9 crouch10 crouch11
$frame broken1 broken2 broken3 broken4 broken5 broken6 broken7 broken8 broken9 broken10 broken11
/*
==============================================================================
PLAYER
==============================================================================
*/

void() player_anim_run;

void()  player_anim_stand1 =[        $idle1,       player_anim_stand1   ]
{
	if( !(self.crouchflags & #CROUCH_OFF) ) 
	{
		return;
	}

	if (self.velocity_x || self.velocity_y)
	{
		self.walkframe=0;
		player_anim_run();
		return;
	}

	if (self.weapon == W_BLASTER)
	{
		if (self.walkframe >= 10)
			self.walkframe = 0;
		self.frame = $idle1 + self.walkframe;
	}
	else
	{
		if (self.walkframe >= 5)
			self.walkframe = 0;
		self.frame = $idle1 + self.walkframe;
	}
	self.walkframe = self.walkframe + 1;    
};

void()  player_anim_run = [   $idle1,      player_anim_run      ]
{
	if( !(self.crouchflags & #CROUCH_OFF) ) 
	{
		return;
	}

	if (!self.velocity_x && !self.velocity_y)
	{
		self.walkframe=0;
		player_anim_stand1();
		return;
	}

	if (self.weapon == W_BLASTER)
	{
		if (self.walkframe >= 10)
			self.walkframe = 0;
		self.frame = $idle1 + self.walkframe;
	}
	else
	{
		if (self.walkframe >= 10)
			self.walkframe = 0;
		self.frame = self.frame + self.walkframe;
	}
	self.walkframe = self.walkframe + 1;
};

// Kkelad Crouch Animations
void() kkelad_anim_crouch_reset = 
{
	self.walkframe=$crouch1;
}
void()  kkelad_anim_crouch_on = [   $crouch1,      player_anim_run      ]
{
	if (self.walkframe >= 20 && self.walkframe < 25 ) {
		self.frame = self.frame + self.walkframe;
		self.walkframe = self.walkframe + 1;
	}
}
void()  kkelad_anim_crouch =
{
		self.frame = $crouch5;
		self.walkframe = $crouch5;
};
void()  kkelad_anim_crouch_off =
{
	if (self.walkframe >= 25 && self.walkframe < 30 ) {
		self.frame = self.frame + self.walkframe;
		self.walkframe = self.walkframe + 1;
	}
};

void()  player_anim_shot1 =  [$idle1, player_anim_shot2        ] {};
void()  player_anim_shot2 =  [$idle2, player_anim_shot3        ] {};
void()  player_anim_shot3 =  [$idle3, player_anim_shot4        ] {};
void()  player_anim_shot4 =  [$idle4, player_anim_shot5        ] {};
void()  player_anim_shot5 =  [$idle5, player_anim_shot6        ] {};
void()  player_anim_shot6 =  [$idle6, player_anim_run  ] {};

void()  player_anim_axe1 =   [$idle1, player_anim_axe2   ] {};
void()  player_anim_axe2 =   [$idle2, player_anim_axe3   ] {};
void()  player_anim_axe3 =   [$idle3, player_anim_axe4   ] {W_FireAxe();};
void()  player_anim_axe4 =   [$idle4, player_anim_run    ] {};

//============================================================================

void() player_nail1   =[$idle1, player_nail2  ] 
{
	if (self.weaponstate == WS_IDLE || intermission_running)
		{player_anim_run ();return;}
};
void() player_nail2   =[$idle2, player_nail1  ]
{
	if (self.weaponstate == WS_IDLE || intermission_running)
		{player_anim_run ();return;}
};

//============================================================================

void() player_light1   =[$idle1, player_light2  ] 
{
	if (self.weaponstate == WS_IDLE || intermission_running)
		{player_anim_run ();return;}
};
void() player_light2   =[$idle2, player_light1  ]
{
	if (self.weaponstate == WS_IDLE || intermission_running)
		{player_anim_run ();return;}
};

//============================================================================


void() player_rocket1   =[$idle1, player_rocket2  ] {};
void() player_rocket2   =[$idle2, player_rocket3  ] {};
void() player_rocket3   =[$idle3, player_rocket4  ] {};
void() player_rocket4   =[$idle4, player_rocket5  ] {};
void() player_rocket5   =[$idle5, player_rocket6  ] {};
void() player_rocket6   =[$idle6, player_anim_run  ] {};
void(float num_bubbles) DeathBubbles;

void() PainSound =
{
	local float rs;
	local string s;

	if (self.health < 0)
		return;

	if (self.pain_finished > time)
		return;

    // TO DO Enhance hitsound // Currently emitted for all
    precache_sound ("wizard/hit.wav");
	//ambientsound (self.origin, "wizard/hit.wav", 1, ATTN_NONE);
    sound (self, CHAN_AUTO, "wizard/hit.wav", 1, ATTN_NONE);

	// change pain sound depending on means of death
	switch (damage_mod)
	{
	case MOD_TELEFRAG:
	case MOD_TELEFRAGDEFLECT:
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	case MOD_DROWN:
		DeathBubbles(1);
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);
		return;
	case MOD_SLIME:
		// FIX ME: put in some steam here
		if (self.waterlevel == 3)
			DeathBubbles(1);
	case MOD_LAVA:
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		return;
	case MOD_AXE:
		sound (self, CHAN_VOICE, "player/axhit1.wav", 1, ATTN_NORM);
		self.pain_finished = time + 0.5;
		return;
	default:
	 	rs = random();

 		s = "sounds/player/crash.wav";
 		if (rs < 0.166)
 			s = "sounds/player/crash.wav";
 		else if (rs < 0.333)
 			s = "sounds/player/crash.wav";
 		else if (rs < 0.5)
 			s = "sounds/player/crash.wav";
 		else if (rs < 0.667)
 			s = "sounds/player/crash.wav";
 		else if (rs < 0.833)
 			s = "sounds/player/crash.wav";

	 	sound (self, CHAN_VOICE, s, 1, ATTN_NORM);
		return;
	}
};

void()  player_pain1 =  [       $idle1, player_pain2    ] {PainSound();};
void()  player_pain2 =  [       $idle2, player_pain3    ] {};
void()  player_pain3 =  [       $idle3, player_pain4    ] {};
void()  player_pain4 =  [       $idle4, player_pain5    ] {};
void()  player_pain5 =  [       $idle5, player_pain6    ] {};
void()  player_pain6 =  [       $idle6, player_anim_run      ] {};

void() player_pain =
{
	if (self.weaponstate != WS_IDLE)
		return;

	if (self.invisible_finished > time)
		return;         // eyes don't have pain frames

	player_pain1 ();
};

void() player_die;

void() DeathBubblesSpawn =
{
local entity    bubble;
	if (self.owner.waterlevel != 3)
	{
		remove(self);
		return;
	}
	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.owner.origin + '0 0 24');
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.bubble_state = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + 0.1;
	self.think = DeathBubblesSpawn;
	self.bubble_count = self.bubble_count - 1;
	if (self.bubble_count <= 0)
		remove(self);
};

void(float num_bubbles) DeathBubbles =
{
local entity    bubble_spawner;
	
	bubble_spawner = spawn();
	setorigin (bubble_spawner, self.origin);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.owner = self;
	bubble_spawner.bubble_count = num_bubbles;
};


void() DeathSound =
{
local float             rs;

	// water death sounds
	if (self.waterlevel == 3)
	{
		DeathBubbles(5);
		sound (self, CHAN_VOICE, "player/h2odeath.wav", 1, ATTN_NONE);
		return;
	}
	
	rs = rint ((random() * 4) + 1);
	if (rs == 1)
		self.noise = "sounds/player/crash.wav";
	if (rs == 2)
		self.noise = "sounds/player/crash.wav";
	if (rs == 3)
		self.noise = "sounds/player/crash.wav";
	if (rs == 4)
		self.noise = "sounds/player/crash.wav";
	if (rs == 5)
		self.noise = "sounds/player/crash.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);
	return;
};


void() PlayerDead =
{
	self.nextthink = -1;
// allow respawn after a certain time
	self.deadflag = DEAD_DEAD;
};

vector(float dm) VelocityForDamage =
{
	local vector v;

	if (vlen(damage_inflictor.velocity)>0)
	{
		v = 0.5 * damage_inflictor.velocity;
		v = v + (25 * normalize(self.origin-damage_inflictor.origin));
		v_z = 100 + 240 * random();
		v_x = v_x + (200 * crandom());
		v_y = v_y + (200 * crandom());
		//dprint ("Velocity gib\n");                
	}
	else
	{
		v_x = 100 * crandom();
		v_y = 100 * crandom();
		v_z = 200 + 100 * random();
	}

	//v_x = 100 * crandom();
	//v_y = 100 * crandom();
	//v_z = 200 + 100 * random();

	if (dm > -50)
	{
	//      dprint ("level 1\n");
		v = v * 0.7;
	}
	else if (dm > -200)
	{
	//      dprint ("level 3\n");
		v = v * 2;
	}
	else
		v = v * 10;

	return v;
};

void(string gibname, float dm) ThrowGib =
{
	local   entity new;

	new = spawn();
	new.origin = self.origin;
	setmodel (new, gibname);
	setsize (new, '0 0 0', '0 0 0');
	new.velocity = VelocityForDamage (dm);
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	new.think = SUB_Remove;
	new.nextthink = time + 10 + random()*10;
	new.frame = 0;
	new.flags = 0;
};

void(string gibname, float dm) ThrowHead =
{
	setmodel (self, gibname);
	self.frame = 0;
	self.nextthink = -1;
	self.movetype = MOVETYPE_BOUNCE;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.view_ofs = '0 0 8';
	setsize (self, '-16 -16 0', '16 16 56');
	self.velocity = VelocityForDamage (dm);
	self.origin_z = self.origin_z - 24;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.avelocity = crandom() * '0 600 0';
};


void() GibPlayer =
{
	ThrowHead ("progs/h_player.mdl", self.health);
	ThrowGib ("progs/gib1.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health);
	ThrowGib ("progs/gib3.mdl", self.health);

	self.deadflag = DEAD_DEAD;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}
		
	if (random() < 0.5)
		sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
	else
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);
};

void() PlayerDropStuff =
{
	local	string	s, t;	

	if (numberserverinfokey("dq") != 0)
	{
		if (self.super_damage_finished > time)
		{
			DropQuad (self.super_damage_finished - time);
			s = ftos(rint(self.super_damage_finished - time));
			t = " lost a quad with ";
			if (deathmatch == 4)
				t = " lost an OctaPower with ";
			bprint4 (PRINT_LOW, self.netname, t, s, " seconds remaining\n");
		}
	}

	if (numberserverinfokey("dr") != 0)
	{
		if (self.invisible_finished > time)
		{
			s = ftos(rint(self.invisible_finished - time));
			bprint4 (PRINT_LOW, self.netname, " lost a ring with ", s, " seconds remaining\n");
			DropRing (self.invisible_finished - time);
		}
	}

	DropBackpack();
}

void() PlayerDie =
{
	local   float   i;
	self.items = self.items - (self.items & IT_INVISIBILITY);

	PlayerDropStuff();

	self.invisible_finished = 0;    // don't die as eyes
	self.invincible_finished = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.modelindex = modelindex_player;    // don't use eyes

	self.weaponmodel="";
	self.view_ofs = '0 0 0';
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.movetype = MOVETYPE_TOSS;
	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;

	if (self.health < -40)
	{
		GibPlayer ();
		return;
	}

	DeathSound();
	
	self.angles_x = 0;
	self.angles_z = 0;
	

	player_die();

};

void() set_suicide_frame =
{       // used by klill command and diconnect command
	if (self.model != "progs/kkelad.md2")
		return; // allready gibbed
	self.frame = $broken11;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.deadflag = DEAD_DEAD;
	self.nextthink = -1;
};

void() set_broken_frame =
{       // used by klill command and diconnect command
	if (self.model != "progs/kkelad.md2")
		return; // allready gibbed
	self.frame = self.walkframe = $broken10;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
};

void()  player_die    =       [       $broken1,       player_die2   ] {};
void()  player_die2   =       [       $broken2,       player_die3   ] {};
void()  player_die3   =       [       $broken3,       player_die4   ] {};
void()  player_die4   =       [       $broken4,       player_die5   ] {};
void()  player_die5   =       [       $broken5,       player_die6   ] {};
void()  player_die6   =       [       $broken6,       player_die7   ] {};
void()  player_die7   =       [       $broken7,       player_die8   ] {};
void()  player_die8   =       [       $broken8,       player_die9   ] {};
void()  player_die9   =       [       $broken9,       player_die10  ] {};
void()  player_die10  =       [       $broken10,      player_die11  ] {};
void()  player_die11  =       [       $broken11,      player_die    ] {PlayerDead();};
