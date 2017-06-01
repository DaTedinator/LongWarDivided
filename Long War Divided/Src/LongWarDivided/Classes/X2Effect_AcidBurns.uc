class X2Effect_AcidBurns extends X2Effect_Persistent;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState) 
{
	local XComGameState_Item SourceWeapon;
	local X2GrenadeTemplate GrenadeTemplate;

	SourceWeapon = AbilityState.GetSourceWeapon();

	if ( AppliedData.EffectRef.ApplyOnTickIndex >= 0 ) 
	{ 
		return 0; 
	}

	if (SourceWeapon != none) 
	{
		GrenadeTemplate = X2GrenadeTemplate(SourceWeapon.GetMyTemplate());
		if (GrenadeTemplate == none) 
		{
			GrenadeTemplate = X2GrenadeTemplate(SourceWeapon.GetLoadedAmmoTemplate(AbilityState));
		}

		if ( GrenadeTemplate != none && (GrenadeTemplate.DataName == 'AcidGrenade' || GrenadeTemplate.DataName == 'AcidGrenadeMk2') ) 
		{
			return CurrentDamage;
		}
	}
	return 0;
}

DefaultProperties
{
}