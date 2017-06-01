//---------------------------------------------------------------------------------------
//  FILE:    X2AbilityCost_SpareShells.uc
//  AUTHOR:  Teddy McCormick
//  PURPOSE: Kind of a hacky way to reload the sawed-off shotgun;
//           I gave it a negative ammo cost and changed the ammo check
//           to make sure it wasn't full.
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------
class X2AbilityCost_SpareShells extends X2AbilityCost;

var int     iAmmo;		//Amount of ammo replenished

simulated function int CalcAmmoCost(XComGameState_Ability Ability, XComGameState_Item ItemState, XComGameState_BaseObject TargetState)
{
	return iAmmo;
}

simulated function name CanAfford(XComGameState_Ability kAbility, XComGameState_Unit ActivatingUnit)
{
	local XComGameState_Item Weapon;
	local StateObjectReference PumpActionRef;
	local int MaxAmmo;

	PumpActionRef = ActivatingUnit.FindAbility('PumpAction');
	if (PumpActionRef.ObjectID == 0)
		MaxAmmo = 2;
	else
		MaxAmmo = 4;

	Weapon = kAbility.GetSourceWeapon();
	if (Weapon != none)
	{
		if (Weapon.Ammo < MaxAmmo)
			return 'AA_Success';
	}	
	
	return 'AA_AmmoFull'; //Nonstandard AA Code?
}

simulated function ApplyCost(XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_BaseObject AffectState, XComGameState_Item AffectWeapon, XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_BaseObject TargetState;
	local XComGameState_Unit Unit;
	local int Cost;

	History = `XCOMHISTORY;
	Unit = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));

	TargetState = History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID);
	Cost = iAmmo;
	//Cost = CalcAmmoCost(kAbility, AffectWeapon, TargetState);

	kAbility.iAmmoConsumed = Cost;

	AffectWeapon.Ammo -= Cost;
}