//---------------------------------------------------------------------------------------
//  FILE:    XMBEffect_ChangeHitResultForAttacker.uc
//  AUTHOR:  xylthixlm
//
//  Changes the result of an attack after all other hit calculations.
//
//  EXAMPLES
//
//  The following examples in Examples.uc use this class:
//
//  Focus
//
//  INSTALLATION
//
//  Install the XModBase core as described in readme.txt. Copy this file, and any files 
//  listed as dependencies, into your mod's Classes/ folder. You may edit this file.
//
//  DEPENDENCIES
//
//  None.
//---------------------------------------------------------------------------------------
class XMBEffect_ChangeHitResultForAttacker extends X2Effect_Persistent;


///////////////////////
// Effect properties //
///////////////////////

var array<EAbilityHitResult> IncludeHitResults;		// Hit results which will be changed
var array<EAbilityHitResult> ExcludeHitResults;		// Hit results which will not be changed
var bool bRequireHit;								// Set true to only change hits
var bool bRequireMiss;								// Set true to only change misses

var EAbilityHitResult NewResult;					// The hit result to change to


//////////////////////////
// Condition properties //
//////////////////////////

var array<X2Condition> AbilityTargetConditions;		// Conditions on the target of the ability being changed
var array<X2Condition> AbilityShooterConditions;	// Conditions on the shooter of the ability being changed


////////////////////
// Implementation //
////////////////////

function bool ChangeHitResultForAttacker(XComGameState_Unit Attacker, XComGameState_Unit TargetUnit, XComGameState_Ability AbilityState, const EAbilityHitResult CurrentResult, out EAbilityHitResult NewHitResult)
{
	local XComGameState_Effect EffectState;

	EffectState = Attacker.GetUnitAffectedByEffectState(EffectName);

	if (ValidateAttack(EffectState, Attacker, TargetUnit, AbilityState) != 'AA_Success')
		return false;

	`Log(self @ "[" $ EffectName $ "]:" @ CurrentResult);

	if (IncludeHitResults.Length > 0 && IncludeHitResults.Find(CurrentResult) == INDEX_NONE)
		return false;
	if (ExcludeHitResults.Length > 0 && ExcludeHitResults.Find(CurrentResult) != INDEX_NONE)
		return false;

	if (bRequireHit && !class'XComGameStateContext_Ability'.static.IsHitResultHit(CurrentResult))
		return false;
	if (bRequireMiss && !class'XComGameStateContext_Ability'.static.IsHitResultMiss(CurrentResult))
		return false;

	NewHitResult = NewResult;
	return true;
}

function private name ValidateAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState)
{
	local name AvailableCode;

	AvailableCode = class'XMBEffectUtilities'.static.CheckTargetConditions(AbilityTargetConditions, EffectState, Attacker, Target, AbilityState);
	if (AvailableCode != 'AA_Success')
		return AvailableCode;
		
	AvailableCode = class'XMBEffectUtilities'.static.CheckShooterConditions(AbilityShooterConditions, EffectState, Attacker, Target, AbilityState);
	if (AvailableCode != 'AA_Success')
		return AvailableCode;
		
	return 'AA_Success';
}

DefaultProperties
{
	NewResult = eHit_Success
}