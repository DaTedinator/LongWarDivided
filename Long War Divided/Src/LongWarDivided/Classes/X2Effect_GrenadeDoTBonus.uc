class X2Effect_GrenadeDoTBonus extends X2Effect_Persistent;

var int BonusDamage;
var array<name> RequiredDamageTypes;		//	If empty, apply to all DoTs

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState) 
{
	local XComGameState_Item SourceWeapon;
	local X2GrenadeTemplate GrenadeTemplate;
	local X2Effect_ApplyWeaponDamage ApplyDamageEffect;
	local array<name> AppliedDamageTypes;
	local name DamageType;

	SourceWeapon = AbilityState.GetSourceWeapon();

	if ( AppliedData.EffectRef.ApplyOnTickIndex < 0 ) 
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

		if (GrenadeTemplate != none) 
		{
			if (RequiredDamageTypes.Length == 0 )
			{
				return BonusDamage;
			}

			ApplyDamageEffect = X2Effect_ApplyWeaponDamage(class'X2Effect'.static.GetX2Effect(AppliedData.EffectRef));
			if (ApplyDamageEffect != none)
			{
				ApplyDamageEffect.GetEffectDamageTypes(NewGameState, AppliedData, AppliedDamageTypes);

				foreach AppliedDamageTypes(DamageType)
				{
					if (RequiredDamageTypes.Find(DamageType) != INDEX_NONE && !TargetDamageable.IsImmuneToDamage(DamageType))
					{
						return BonusDamage;
					}
				}
			}
		}
	}
	return 0;
}

DefaultProperties
{
	BonusDamage = 1
	DuplicateResponse = eDupe_Allow
}