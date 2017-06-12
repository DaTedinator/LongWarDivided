class X2Effect_AdjustRangePenalty extends X2Effect_Persistent;

var float Multiplier;			//	Multiply range modifier by this
var int WithinTiles;			//	Only has any effect within this many tiles
var int OutsideTiles;			//	Only has any effect outside this many tiles
var int FlatMod;				//	Add this to range modifier
var int PastMax;				//	The effect extends this many tiles past the weapon's maximum range; -1 == unlimited
var int PastMaxMultiplier;		//
var int PastMaxFlatMod;			//
var bool bOnlyGood, bOnlyBad;	//	if bOnlyGood, only provide aim bonuses (i.e. reduce range penalties); 
								//	if bOnlyBad, only provide aim maluses (i.e., reduce range bonuses);

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
		if( Tiles < RangeTable.Length && Tiles < WithinTiles && Tiles > OutsideTiles )
        {
			Modifier = (RangeTable[Tiles] * Multiplier) + FlatMod;
        }
		else if ( Tiles < RangeTable.Length + PastMax && Tiles < WithinTiles && Tiles > OutsideTiles )
		{
			Modifier = (RangeTable[RangeTable.Length - 1] * PastMaxMultiplier) + PastMaxFlatMod;
		}

		if ( (bOnlyGood && Modifier < 0) || (bOnlyBad && Modifier > 0) ) {Modifier = 0;}

		if(Modifier != 0)
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
	WithinTiles = 1000
	OutsideTiles = -1
    Multiplier = 1.0
	FlatMod = 0
	PastMax = 0
	PastMaxMultiplier = 1.0
	PastMaxFlatMod = 0
	bOnlyBon = false
	bOnlyMal = false
}