class X2Effect_TightChoke extends X2Effect_Persistent config (LWD_Abilities);

var config int TightChokeBonus;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)

{
	local XComGameState_Item	SourceWeapon;
	local ShotModifierInfo		ShotInfo;
	local array<int>			RangeTable;
	local X2WeaponTemplate		WeaponTemplate;
    local int					Tiles, Modifier;

	SourceWeapon = AbilityState.GetSourceWeapon();    
	if(SourceWeapon != none)
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		RangeTable = WeaponTemplate.RangeAccuracy;
		Tiles = Attacker.TileDistanceBetween(Target); 
		Modifier = 0;
		if(Tiles < RangeTable.Length)
        {
			if(RangeTable[Tiles] < 0)
			{
				Modifier = (-RangeTable[Tiles] / 2)+10;
			}
			else if(RangeTable[Tiles] == 0)
			{
				Modifier = TightChokeBonus;
			}
        }            
        else if(Tiles < (RangeTable.Length + 4))
        {
            Modifier = 40;
        }
		if(Modifier > 0)
		{
			ShotInfo.Value = Modifier;
		}
		ShotInfo.ModType = eHit_Success;
        ShotInfo.Reason = FriendlyName;
        ShotModifiers.AddItem(ShotInfo);
    } 
}

defaultproperties
{
    EffectName="TightChoke"
}