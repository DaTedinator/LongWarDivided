class X2Ability_LWD_FieldScientistAbilitySet extends XMBAbility
	dependson(X2Ability_DefaultAbilitySet)
	config(LWD_SoldierSkills);

var config int JuicedCooldown;
var config int ClearCooldown;
var config int HotwireCooldown, HotwireBaseValue;
var config WeaponDamageValue ShortCircuitDamage;
var config int SkullminerBonusCharges;
var config float ScriptKiddieBonusRadius;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(Juiced('LWD_Juiced', "img:///UILibrary_LWD.ability_Juiced"));
	Templates.AddItem(Clear('LWD_Clear', "img:///UILibrary_LWD.ability_Clear"));
	Templates.AddItem(Hotwire('LWD_Hotwire', "img:///UILibrary_LWD.ability_Hotwire"));
	Templates.AddItem(PurePassive('LWD_ShortCircuit', "img:///UILibrary_LWD.ability_ShortCircuit"));
	Templates.AddItem(Skullminer('LWD_Skullminer', "img:///UILibrary_LWD.ability_Skullminer"));
	Templates.AddItem(ScriptKiddie('LWD_ScriptKiddie', "img:///UILibrary_LWD.ability_ScriptKiddie"));
	Templates.AddItem(GreasedLightning('LWD_GreasedLightning', "img:///UILibrary_LWD.ability_GreasedLightning"));
	//Templates.AddItem(('LWD_', "img:///UILibrary_LWD.ability_"));

	return Templates;
}

static function X2AbilityTemplate Juiced(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCooldown					Cooldown;
	local X2Effect_GrantActionPoints		ActionPointEffect;
	local X2Effect_Persistent				ActionPointPersistEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	Template.IconImage = ImageIcon;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.ShotHUDPriority = 319;
	Template.bLimitTargetIcons = true;
	Template.AddShooterEffectExclusions();

	Template.AbilityCosts.AddItem(ActionPointCost(eCost_Single));

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.JuicedCooldown;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.Deadeye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	Template.AbilityTargetConditions.AddItem(default.LivingFriendlyTargetProperty);

	ActionPointEffect = new class'X2Effect_GrantActionPoints';
    ActionPointEffect.NumActionPoints = 1;
    ActionPointEffect.PointType = class'X2CharacterTemplateManager'.default.MoveActionPoint;
    Template.AddTargetEffect(ActionPointEffect);

	ActionPointPersistEffect = new class'X2Effect_Persistent';
    ActionPointPersistEffect.EffectName = 'Juiced';
    ActionPointPersistEffect.BuildPersistentEffect(1, false, true, false, 8);
    ActionPointPersistEffect.bRemoveWhenTargetDies = true;
    Template.AddTargetEffect(ActionPointPersistEffect);

	Template.bShowActivation = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

// Perk name:		Clear!
// Perk effect:		Revive an ally who is unconscious or bleeding out, but they cannot act this turn, and have one fewer action next turn. Shares a cooldown with Juiced.
static function X2AbilityTemplate Clear(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCooldown					Cooldown;
	local X2Effect_RemoveEffects			RemoveBleedingOut;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	Template.AbilityCosts.AddItem(ActionPointCost(eCost_Single));

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.ClearCooldown;
	Template.AbilityCooldown = Cooldown;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SingleTargetWithSelf;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetConditions.AddItem(new class'X2Condition_Clear');

	RemoveBleedingOut = new class'X2Effect_RemoveEffects';
	RemoveBleedingOut.EffectNamesToRemove.AddItem(class'X2StatusEffects'.default.BleedingOutName);
	Template.AddTargetEffect(RemoveBleedingOut);
	Template.AddTargetEffect(class'X2StatusEffects'.static.CreateUnconsciousStatusEffect());

	//Template.AddTargetEffect(RemoveAdditionalEffectsForClear());
	//Template.AddTargetEffect(new class'X2Effect_RestoreActionPoints');      // This would put the unit back to full actions, but we don't want that.

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.IconImage = ImageIcon;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.Hostility = eHostility_Defensive;
	Template.bDisplayInUITooltip = false;
	Template.bLimitTargetIcons = true;
	Template.AbilitySourceName = 'eAbilitySource_Perk';

	Template.ActivationSpeech = 'StabilizingAlly';

	Template.bShowActivation = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

// Perk name:		Hotwire
// Perk effect:		Use your arc thrower to stun or potentially control a mechanical enemy
static function X2AbilityTemplate Hotwire(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate							Template;
	local X2AbilityCost_ActionPoints				ActionPointCost;
	local X2AbilityToHitCalc_Hotwire				ToHit;
	local X2Condition_UnitProperty					UnitPropertyCondition;
	local X2Effect_PersistentStatChange				DisorientedEffect;
	local X2Effect_Stunned							StunnedEffect; 
	local X2Effect_MindControl						MindControlEffect;
	local X2AbilityCooldown							Cooldown; 
	local X2Effect_ApplyWeaponDamage				RuptureEffect;
	local X2Condition_AbilityProperty				ShortCircuitCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.HotwireCooldown;
	Template.AbilityCooldown = Cooldown;
	
	ToHit = new class'X2AbilityToHitCalc_Hotwire';
	ToHit.BaseValue = default.HotwireBaseValue;
	Template.AbilityToHitCalc = ToHit;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.ExcludeDead = true;
	UnitPropertyCondition.ExcludeFriendlyToSource = true;
	UnitPropertyCondition.ExcludeOrganic = true;
	UnitPropertyCondition.FailOnNonUnits = true;
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);	
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	//  Disorient effect for 1 unblocked hit
	DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect(false, 0.0, false);
	DisorientedEffect.iNumTurns = 2;
	DisorientedEffect.MinStatContestResult = 1;
	DisorientedEffect.MaxStatContestResult = 1;     
	DisorientedEffect.DamageTypes.AddItem('Electrical');
	Template.AddTargetEffect(DisorientedEffect);

	//  Longer Disorient effect for 2 unblocked hits
	DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect(false, 0.0, false);
	DisorientedEffect.iNumTurns = 3;
	DisorientedEffect.MinStatContestResult = 2;
	DisorientedEffect.MaxStatContestResult = 2;     
	DisorientedEffect.DamageTypes.AddItem('Electrical');
	Template.AddTargetEffect(DisorientedEffect);
	
	//  Stun effect for 3-4 unblocked hits
	StunnedEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100, false);
	StunnedEffect.MinStatContestResult = 3;
	StunnedEffect.MaxStatContestResult = 4;
	StunnedEffect.DamageTypes.AddItem('Electrical');
	Template.AddTargetEffect(StunnedEffect);

	//  Mind control effect for 5+ unblocked hits
	MindControlEffect = class'X2StatusEffects'.static.CreateMindControlStatusEffect(1, true, false);
	MindControlEffect.MinStatContestResult = 5;
	MindControlEffect.MaxStatContestResult = 0;
	MindControlEffect.DamageTypes.AddItem('Electrical');
	Template.AddTargetEffect(MindControlEffect);

	//  Rupture effect if the user has Short Circuit
	RuptureEffect = new class'X2Effect_ApplyWeaponDamage';
	RuptureEffect.bIgnoreBaseDamage = true;
	RuptureEffect.EffectDamageValue = default.ShortCircuitDamage;
	RuptureEffect.MinStatContestResult = 1;
	RuptureEffect.MaxStatContestResult = 0;
	RuptureEffect.bIgnoreArmor = true;
	ShortCircuitCondition = new class'X2Condition_AbilityProperty';
	ShortCircuitCondition.OwnerHasSoldierAbilities.AddItem('LWD_ShortCircuit');
	RuptureEffect.TargetConditions.AddItem(ShortCircuitCondition);
	Template.AddTargetEffect(RuptureEffect);

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.IconImage = ImageIcon;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;

	Template.ActivationSpeech = 'HotwireProtocol';

	// This action is considered 'hostile' and can be interrupted!
	Template.Hostility = eHostility_Offensive;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;
	
	return Template;
}

// Perk name:		Skullminer
// Perk effect:		You gain two extra charges of skullmining when equipped with a skulljack
static function X2AbilityTemplate Skullminer(name TemplateName, string ImageIcon)
{
	local XMBEffect_AddAbilityCharges Effect;
	local X2AbilityTemplate Template;

	Effect = new class'XMBEffect_AddAbilityCharges';
	Effect.AbilityNames.AddItem('SKULLMINEAbility');
	Effect.BonusCharges = default.SkullminerBonusCharges;

	// The effect isn't an X2Effect_Persistent, so we can't use it as the effect for Passive(). Let
	// Passive() create its own effect.
	Template = Passive(TemplateName, ImageIcon, true);

	AddSecondaryEffect(Template, Effect);

	return Template;
}

// Perk name:		Script Kiddie
// Perk effect:		You always carry an EMP grenade into battle. The area of your EMP grenades is increased.
static function X2AbilityTemplate ScriptKiddie(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;
	local XMBEffect_BonusRadius RadiusEffect;

	ItemEffect = new class 'XMBEffect_AddUtilityItem';
	ItemEffect.DataName = 'EMPGrenade';
	ItemEffect.BonusCharges = 1;
	
	Template = Passive(TemplateName, ImageIcon, true, ItemEffect);

	// Create a bonus radius effect
	RadiusEffect = new class'XMBEffect_BonusRadius';
	RadiusEffect.EffectName = 'ScriptKiddie';
	RadiusEffect.IncludeItemNames.AddItem('EMPGrenade');
	RadiusEffect.IncludeItemNames.AddItem('EMPGrenadeMk2');

	// Add 1m (.66 tiles) to the radius of all grenades
	RadiusEffect.fBonusRadius = default.ScriptKiddieBonusRadius;

	AddSecondaryEffect(Template, RadiusEffect);

	return Template;
}

// Perk name:		Greased Lightning
// Perk effect:		Using your Arc Thrower no longer ends your turn
static function X2AbilityTemplate GreasedLightning(name TemplateName, string ImageIcon)
{
	local XMBEffect_DoNotConsumeAllPoints Effect;

	// Create an effect that causes standard attacks to not end the turn (as the first action)
	Effect = new class'XMBEffect_DoNotConsumeAllPoints';
	Effect.AbilityNames.AddItem('ArcthrowerStun');
	Effect.AbilityNames.AddItem('EMPulser');
	Effect.AbilityNames.AddItem('LWD_Hotwire');

	// Create the template using a helper function
	return Passive(TemplateName, ImageIcon, false, Effect);
}

// Perk name:		
// Perk effect:		
//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
//{
//	
//}