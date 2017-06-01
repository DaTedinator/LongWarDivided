class X2Effect_PyromancerPierce extends X2Effect_Persistent;

var int PierceAmount;

function int GetExtraArmorPiercing(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData) 
{ 
	local XComGameState_Item SourceWeapon;
	local X2GrenadeTemplate GrenadeTemplate;

	SourceWeapon = AbilityState.GetSourceWeapon();

	if (SourceWeapon != none)
	{
		GrenadeTemplate = X2GrenadeTemplate(SourceWeapon.GetMyTemplate());

		if (GrenadeTemplate == none)
		{
			GrenadeTemplate = X2GrenadeTemplate(SourceWeapon.GetLoadedAmmoTemplate(AbilityState));
		}

		if ( GrenadeTemplate != none && (GrenadeTemplate.DataName == 'Firebomb' || GrenadeTemplate.DataName == 'FirebombMK2') )
		{
			return PierceAmount;
		}
	}
	return 0;
}

DefaultProperties
{
	PierceAmount = 1000
}