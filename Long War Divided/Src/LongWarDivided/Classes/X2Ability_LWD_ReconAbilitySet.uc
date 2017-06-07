class X2Ability_LWD_ReconAbilitySet extends TeddyXMBAbility
	config(LWD_SoldierSkills);

var config int ScannerSweepWidth, ScannerSweepLength, ScannerSweepCooldown;
var config int EagleEyesVisionBonus, EagleEyesCritBonus;
var config int WatchmanSightBonus, WatchmanDodgeBonus;
var config int LookoutAimPenalty;
var config int GhostPassiveReduction, GhostActiveReduction, GhostDuration, GhostCooldown;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(ScannerSweep('LWD_ScannerSweep', "img:///UILibrary_LWD.ability_scannersweep"));
	Templates.AddItem(EagleEyes('LWD_EagleEyes', "img:///UILibrary_LWD.ability_eagleeyes"));
	Templates.AddItem(Watchman('LWD_Watchman', "img:///UILibrary_LWD.ability_Watchman"));
	Templates.AddItem(Lookout('LWD_Lookout', "img:///UILibrary_LWD.ability_Lookout"));
	Templates.AddItem(GhostPassive('LWD_GhostPassive', "img:///UILibrary_LWD.ability_Ghost"));
	Templates.AddItem(GhostActive('LWD_GhostActive', "img:///UILibrary_LWD.ability_Ghost"));

	return Templates;
}

static function X2AbilityTemplate ScannerSweep(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2AbilityMultiTarget_Cone ConeMultiTarget;
	//local XMBEffect_RevealUnit ScanEffect;
	local X2Effect_ScanningProtocol ScanEffect;
	local X2AbilityCooldown Cooldown;
	local X2AbilityTarget_Cursor CursorTarget;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2Condition_UnitProperty CivilianProperty;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.IconImage = ImageIcon;
	Template.AbilityConfirmSound = "TacticalUI_ActivateAbility";
	Template.bLimitTargetIcons = true;
	Template.Hostility = eHostility_Neutral;

	Template.bShowActivation = false;
	Template.bSkipFireAction = false;
	Template.ConcealmentRule = eConceal_Always;

	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	ConeMultiTarget = new class'X2AbilityMultiTarget_Cone';
	ConeMultiTarget.bUseWeaponRadius = true;
	ConeMultiTarget.ConeEndDiameter = default.ScannerSweepWidth * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.ConeLength = default.ScannerSweepLength * class'XComWorldData'.const.WORLD_StepSize;
	ConeMultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = ConeMultiTarget;

	Template.TargetingMethod = class'X2TargetingMethod_Cone';

	//Template.AbilityCosts.AddItem(ActionPointCost(eCost_Single));
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.ScannerSweepCooldown;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.DeadEye;

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	ScanEffect = new class'X2Effect_ScanningProtocol';
	ScanEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
	ScanEffect.TargetConditions.AddItem(default.LivingHostileUnitOnlyProperty);
	Template.AddMultiTargetEffect(ScanEffect);

	ScanEffect = new class'X2Effect_ScanningProtocol';
	ScanEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
	CivilianProperty = new class'X2Condition_UnitProperty';
	CivilianProperty.ExcludeNonCivilian = true;
	CivilianProperty.ExcludeHostileToSource = false;
	CivilianProperty.ExcludeFriendlyToSource = false;
	ScanEffect.TargetConditions.AddItem(CivilianProperty);
	Template.AddMultiTargetEffect(ScanEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.bCrossClassEligible = false;

	Template.ActivationSpeech = 'ScanningProtocol';

	return Template;
}//Scanner Sweep

static function X2AbilityTemplate EagleEyes(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_PersistentStatChange Effect;

	// Create a persistent stat change effect
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'EagleEyes';

	// The effect doesn't expire
	Effect.BuildPersistentEffect(1, true, false, false);

	// The effect gives +3 sight radius and +5% crit chance
	Effect.AddPersistentStatChange(eStat_SightRadius, default.EagleEyesVisionBonus);
	Effect.AddPersistentStatChange(eStat_CritChance, default.EagleEyesCritBonus);

	// Add the stat change as a secondary effect of the passive. It will be applied at the start
	// of battle.
	Template = Passive(TemplateName, ImageIcon, true, Effect);

	return Template;
}//Eagle Eyes

static function X2AbilityTemplate Watchman(name TemplateName, string ImageIcon)
{
	local X2Effect_PersistentStatChange Effect;
	local X2AbilityTemplate Template;
	local XMBCondition_AbilityName Condition;

	// Create a persistent stat change effect
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'Watchman';

	// The effect lasts until the end of the player's turn
	Effect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);

	// If the effect is added multiple times, it refreshes the duration of the existing effect
	Effect.DuplicateResponse = eDupe_Ignore;

	// The effect provides bonuses to sight and dodge
	Effect.AddPersistentStatChange(eStat_SightRadius, default.WatchmanSightBonus);
	Effect.AddPersistentStatChange(eStat_Dodge, default.WatchmanDodgeBonus);

	// The effect only applies to living, friendly targets
	Effect.TargetConditions.AddItem(default.LivingFriendlyTargetProperty);

	// Create the template using a helper function. This ability triggers when we activate an ability.
	Template = SelfTargetTrigger(TemplateName, ImageIcon, true, Effect, 'AbilityActivated');

	Condition = new class'XMBCondition_AbilityName';
	Condition.IncludeAbilityNames.AddItem('Overwatch');
	Condition.IncludeAbilityNames.AddItem('PistolOverwatch');
	Condition.IncludeAbilityNames.AddItem('SniperRifleOverwatch');
	Condition.IncludeAbilityNames.AddItem('LWD_StandWatch');
	Condition.IncludeAbilityNames.AddItem('LWD_PerfectWatch');
	AddTriggerTargetCondition(Template, Condition);

	// Trigger abilities don't appear as passives. Add a passive ability icon.
	AddIconPassive(Template);

	return Template;
}//Watchman

static function X2AbilityTemplate Lookout(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate					Template;
	local X2Effect_PersistentStatChange		Effect;

	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'LookoutMark';
	Effect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	Effect.DuplicateResponse = eDupe_Refresh;
	Effect.AddPersistentStatChange(eStat_Offense, default.LookoutAimPenalty);

	// The effect only applies to living, hostile targets
	Effect.TargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);

	Template = OnHitDebuff(TemplateName, ImageIcon, false, Effect, class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY, eHit_Success);

	AddTriggerTargetCondition(Template, default.MatchingWeaponCondition);

	AddIconPassive(Template);

	return Template;
}//Lookout
	
static function X2AbilityTemplate GhostPassive(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate					Template;
	local X2Effect_PersistentStatChange		Effect;

	Effect = new class'X2Effect_PersistentStatChange';
	Effect.AddPersistentStatChange(eStat_DetectionModifier, default.GhostPassiveReduction);

	Template = Passive(TemplateName, ImageIcon, true, Effect);

	Template.AdditionalAbilities.AddItem('LWD_GhostActive');

	return Template;
}//Ghost
	
static function X2AbilityTemplate GhostActive(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate					Template;
	local X2Effect_PersistentStatChange		Effect;
	local X2Condition_Concealed				Condition;

	Effect = new class'X2Effect_PersistentStatChange';
	Effect.AddPersistentStatChange(eStat_DetectionModifier, default.GhostActiveReduction);
	Effect.BuildPersistentEffect(default.GhostDuration,false,true,false,eGameRule_PlayerTurnBegin);

	Template = SelfTargetActivated(TemplateName, ImageIcon, false, Effect, class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY, eCost_Free);

	Condition = new class'X2Condition_Concealed';
	Template.AbilityTargetConditions.AddItem(Condition);

	AddCooldown(Template, default.GhostCooldown);

	return Template;
}//GhostActivated
	
//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
//{
//	
//}