class X2Ability_LWD_ChemistAbilitySet extends TeddyXMBAbility
	config(LWD_SoldierSkills);

var config int HISHPBonus;
var config int CloudkillBonusRadius;
var config int ThirdDegreeDamage;
var config int AADam, AASpread, AADoTDam, AADoTSpread, AADoTChance;
var config float FrostlordBonusRadius;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(Gasser('LWD_Gasser', "img:///UILibrary_LWD.ability_Gasser"));
	Templates.AddItem(HeightenedImmuneSystem('LWD_HeightenedImmuneSystem', "img:///UILibrary_LWD.ability_HeightenedImmuneSystem"));
	Templates.AddItem(Cloudkill('LWD_Cloudkill', "img:///UILibrary_LWD.ability_TearGas"));
	Templates.AddItem(Pyromancer('LWD_Pyromancer', "img:///UILibrary_LWD.ability_Pyromancer"));
	Templates.AddItem(ThirdDegree('LWD_ThirdDegree', "img:///UILibrary_LWD.ability_ThirdDegree"));
	Templates.AddItem(CausticPersonality('LWD_CausticPersonality', "img:///UILibrary_LWD.ability_CausticPersonality"));
	Templates.AddItem(AcidBurns('LWD_AcidBurns', "img:///UILibrary_LWD.ability_AcidBurns"));
	Templates.AddItem(AlkalineArmor('LWD_AlkalineArmor', "img:///UILibrary_LWD.ability_AlkalineArmor"));
	Templates.AddItem(Frostlord('LWD_Frostlord', "img:///UILibrary_LWD.ability_Frostlord"));
	Templates.AddItem(MadChemist('LWD_MadChemist', "img:///UILibrary_LWD.ability_MadChemist"));
	//Templates.AddItem(('LWD_', "img:///UILibrary_LWD.ability_"));

	return Templates;
}


// Perk name:		Gasser
// Perk effect:		Grants 1 free gas grenade item to your inventory
static function X2AbilityTemplate Gasser(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;

	ItemEffect = new class 'XMBEffect_AddUtilityItem';
	ItemEffect.DataName = 'GasGrenade';
	ItemEffect.BonusCharges = 1;
	
	Template = Passive(TemplateName, ImageIcon, true, ItemEffect);

	return Template;
}

// Perk name:		Heightened Immune System
// Perk effect:		You gain immunity to poison, and your recovery times are reduced.
static function X2AbilityTemplate HeightenedImmuneSystem(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_DamageImmunity Effect;
	local X2Effect_FasterRecovery RecoverEffect;

	// Poison immunity
	Effect = new class'X2Effect_DamageImmunity';
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.ImmuneTypes.AddItem('Poison');
	Effect.ImmuneTypes.AddItem('ParthenogenicPoison');

	// Make the template
	Template = Passive(TemplateName, ImageIcon, true, Effect);

	//Reduced recovery times
	RecoverEffect = new class'X2Effect_FasterRecovery';
	RecoverEffect.BuildPersistentEffect (1, true, false);
	AddSecondaryEffect(Template, RecoverEffect);

	return Template;
}

// Perk name:		Cloudkill
// Perk effect:		The radius of your gas grenades is increased by 2.
static function X2AbilityTemplate Cloudkill(name TemplateName, string ImageIcon)
{
	local XMBEffect_BonusRadius Effect;

	// Create a bonus radius effect
	Effect = new class'XMBEffect_BonusRadius';
	Effect.EffectName = 'Cloudkill';
	Effect.IncludeItemNames.AddItem('GasGrenade');
	Effect.IncludeItemNames.AddItem('GasGrenadeMk2');

	// Add 2m (1.33 tiles) to the radius of all grenades
	Effect.fBonusRadius = default.CloudkillBonusRadius;

	return Passive(TemplateName, ImageIcon, true, Effect);
}

// Perk name:		Pyromancer
// Perk effect:		You are immune to fire damage; your incendiary grenades ignore armor
static function X2AbilityTemplate Pyromancer(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_DamageImmunity Effect;
	local X2Effect_PyromancerPierce PierceEffect;

	Effect = new class'X2Effect_DamageImmunity';
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.ImmuneTypes.AddItem('Fire');

	Template = Passive(TemplateName, ImageIcon, false, Effect);

	PierceEffect = new class'X2Effect_PyromancerPierce';
	AddSecondaryEffect(Template, PierceEffect);

	return Template;
}

// Perk name:		Third-Degree
// Perk effect:		Your incendiary grenades deal more damage over time
static function X2AbilityTemplate ThirdDegree(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_GrenadeDoTBonus Effect;

	Effect = new class'X2Effect_GrenadeDoTBonus';
	Effect.RequiredDamageTypes.AddItem('Fire');
	Effect.BonusDamage = default.ThirdDegreeDamage;

	Template = Passive(TemplateName, ImageIcon, false, Effect);

	return Template;
}

// Perk name:		Caustic Personality
// Perk effect:		Grants 1 free acid grenade item to your inventory
static function X2AbilityTemplate CausticPersonality(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;

	ItemEffect = new class 'XMBEffect_AddUtilityItem';
	ItemEffect.DataName = 'AcidGrenade';
	ItemEffect.BonusCharges = 1;
	
	Template = Passive(TemplateName, ImageIcon, true, ItemEffect);

	return Template;
}

// Perk name:		Acid Burns
// Perk effect:		Your acid grenades' explosions deal double damage.
static function X2AbilityTemplate AcidBurns(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_AcidBurns DamageEffect;

	Template = Passive(TemplateName, ImageIcon, false, none);

	DamageEffect = new class'X2Effect_AcidBurns';
	AddSecondaryEffect(Template, DamageEffect);

	return Template;
}

// Perk name:		Alkaline Armor
// Perk effect:		You are immune to acid damage; enemies who attack you in melee take heavy acid damage.
static function X2AbilityTemplate AlkalineArmor(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_DamageImmunity Effect;

	Effect = new class'X2Effect_DamageImmunity';
	Effect.BuildPersistentEffect(1, true, false, false);
	Effect.ImmuneTypes.AddItem('Acid');

	Template = Passive(TemplateName, ImageIcon, false, Effect);

	AddSecondaryAbility(Template, AlkalineDamage());

	return Template;
}

static function X2AbilityTemplate AlkalineDamage()
{
	local X2AbilityTemplate						Template;
	local X2Effect_ApplyWeaponDamage            DamageEffect;
	local X2AbilityTrigger_EventListener        EventTrigger;
	local X2Effect_Burning                      BurningEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LWD_AlkalineDamage');

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Defensive;
	Template.IconImage = "img:///UILibrary_LWD.ability_AlkalineArmor";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	DamageEffect.EffectDamageValue.Damage = default.AADam;
	DamageEffect.EffectDamageValue.Spread = default.AASpread;
	DamageEffect.DamageTypes.AddItem('Acid');
	Template.AddTargetEffect(DamageEffect);

	BurningEffect = class'X2StatusEffects'.static.CreateAcidBurningStatusEffect(default.AADoTDam, default.AADoTSpread);
	BurningEffect.ApplyChance = default.AADoTChance;
	Template.AddTargetEffect(BurningEffect);

	EventTrigger = new class'X2AbilityTrigger_EventListener';
	EventTrigger.ListenerData.EventID = 'AbilityActivated';
	EventTrigger.ListenerData.Filter = eFilter_None;
	EventTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.ScorchCircuits_AbilityActivated;
	Template.AbilityTriggers.AddItem(EventTrigger);

	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	Template.FrameAbilityCameraType = eCameraFraming_Never;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.VisualizationTrackInsertedFn = ScorchCircuits_VisualizationTrackInsert;

	return Template;
}

// Perk name:		Frostlord
// Perk effect:		Grants 1 free frost grenade item to your inventory
//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
static function X2AbilityTemplate Frostlord(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;
	local XMBEffect_BonusRadius Effect;

	ItemEffect = new class 'XMBEffect_AddUtilityItem';
	ItemEffect.DataName = 'Frostbomb';
	ItemEffect.BonusCharges = 1;
	
	Template = Passive(TemplateName, ImageIcon, true, ItemEffect);

	// Create a bonus radius effect
	Effect = new class'XMBEffect_BonusRadius';
	Effect.EffectName = 'Frostlord';
	Effect.IncludeItemNames.AddItem('Frostbomb');

	// Add 2m (1.33 tiles) to the radius of all grenades
	Effect.fBonusRadius = default.FrostlordBonusRadius;

	AddSecondaryEffect(Template, Effect);

	return Template;
}

// Perk name:		Mad Chemist
// Perk effect:		Your grenades deal half damage, but you carry an extra gas, poison, and incendiary grenade.
static function X2AbilityTemplate MadChemist(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_MadChemistReduction Effect;
	local XMBEffect_AddUtilityItem GasEffect;
	local XMBEffect_AddUtilityItem FireEffect;
	local XMBEffect_AddUtilityItem AcidEffect;

	Effect = new class 'X2Effect_MadChemistReduction';
	
	Template = Passive(TemplateName, ImageIcon, true, Effect);

	GasEffect = new class 'XMBEffect_AddUtilityItem';
	GasEffect.DataName = 'GasGrenade';
	AddSecondaryEffect(Template, GasEffect);

	FireEffect = new class 'XMBEffect_AddUtilityItem';
	FireEffect.DataName = 'Firebomb';
	AddSecondaryEffect(Template, FireEffect);

	AcidEffect = new class 'XMBEffect_AddUtilityItem';
	AcidEffect.DataName = 'AcidGrenade';
	AddSecondaryEffect(Template, AcidEffect);

	return Template;
}

// Perk name:		
// Perk effect:		
//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
//{
//	
//}

static function ScorchCircuits_VisualizationTrackInsert(out array<VisualizationTrack> VisualizationTracks, XComGameStateContext_Ability Context, int OuterIndex, int InnerIndex)
{
	local int TrackIndex;
	local X2Action_ApplyWeaponDamageToUnit DamageAction;
	local X2Action_EnterCover EnterCoverAction;

	if (XGUnit(`XCOMHISTORY.GetVisualizer(Context.InputContext.PrimaryTarget.ObjectID)) == VisualizationTracks[OuterIndex].TrackActor)
	{
		//Look for the EnteringCover action for the target and prevent the delay from happening because the ApplyWeaponDamage action should happen immediately.
		for (TrackIndex = InnerIndex - 1; TrackIndex >= 0; --TrackIndex)
		{
			EnterCoverAction = X2Action_EnterCover(VisualizationTracks[OuterIndex].TrackActions[TrackIndex]);
			if (EnterCoverAction != none)
			{
				EnterCoverAction.bInstantEnterCover = true;
				break;
			}
		}
	}
	else
	{
		//Look for the ApplyWeaponDamage action for the source and prevent waiting on the hit animation to end since the counterattack needs to happen immediately.
		for (TrackIndex = InnerIndex - 1; TrackIndex >= 0; --TrackIndex)
		{
			DamageAction = X2Action_ApplyWeaponDamageToUnit(VisualizationTracks[OuterIndex].TrackActions[TrackIndex]);
			if (DamageAction != none)
			{
				DamageAction.bSkipWaitForAnim = true;
				break;
			}
		}
	}
}