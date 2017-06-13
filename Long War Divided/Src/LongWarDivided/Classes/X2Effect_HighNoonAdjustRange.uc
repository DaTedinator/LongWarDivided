class X2Effect_HighNoonAdjustRange extends X2Effect_Persistent;

//////////////////////////
// Condition properties //
//////////////////////////

var array<X2Condition> AbilityTargetConditions;		// Conditions on the target of the ability being modified.
var array<X2Condition> AbilityShooterConditions;	// Conditions on the shooter of the ability being modified.

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)

{
	local XComGameState_Item	SourceWeapon;
	local ShotModifierInfo		ShotInfo;
	local array<int>			RangeTable;
	local X2WeaponTemplate		WeaponTemplate;
    local int					Tiles, Modifier;
	local bool					bMarked;

	if (ValidateAttack(EffectState, Attacker, Target, AbilityState) != 'AA_Success')
		return;

	SourceWeapon = AbilityState.GetSourceWeapon();

	bMarked = MarkCheck(Attacker, Target);

	if(SourceWeapon != none)
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		RangeTable = WeaponTemplate.RangeAccuracy;
		Tiles = Attacker.TileDistanceBetween(Target); 
		Modifier = 0;
		if( Tiles < RangeTable.Length )
        {
			if (bMarked && RangeTable[Tiles] < 0)
			{
				Modifier = -RangeTable[Tiles];
			}
			else if (!bMarked && RangeTable[Tiles] < 0)
			{
				Modifier = RangeTable[Tiles];
			}
        }
		else
		{
			if (bMarked && RangeTable[RangeTable.Length - 1] < 0)
			{
				Modifier = -RangeTable[RangeTable.Length - 1];
			}
			else if (!bMarked && RangeTable[RangeTable.Length - 1] < 0)
			{
				Modifier = RangeTable[RangeTable.Length - 1];
			}
		}

		if(Modifier != 0)
		{
			ShotInfo.Value = Modifier;
		}
		ShotInfo.ModType = eHit_Success;
        ShotInfo.Reason = FriendlyName;
        ShotModifiers.AddItem(ShotInfo);
    } 
}

function bool MarkCheck(XComGameState_Unit Attacker, XComGameState_Unit Target)
{
	local XComGameStateHistory History;
	local XComGameState_Effect Effect;
	local int i;

	History = `XCOMHISTORY;

	for (i = 0; i < Target.AffectedByEffectNames.length; i++)
		{
			if (Target.AffectedByEffectNames[i] == 'HighNoonMark')
			{
				Effect = XComGameState_Effect(History.GetGameStateForObjectID(Target.AffectedByEffects[i].ObjectID));
				if (Effect.ApplyEffectParameters.SourceStateObjectRef.ObjectID == Attacker.ObjectID)
				{
					return true;
				}
			}
		}
	return false;
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

defaultproperties
{
	EffectName="UsingHighNoon"
}