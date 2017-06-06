class X2Effect_HighNoonAdjustRange extends X2Effect_Persistent;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)

{
	local XComGameState_Item	SourceWeapon;
	local ShotModifierInfo		ShotInfo;
	local array<int>			RangeTable;
	local X2WeaponTemplate		WeaponTemplate;
    local int					Tiles, Modifier;
	local bool					bMarked;

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

defaultproperties
{
	EffectName="UsingHighNoon"
}