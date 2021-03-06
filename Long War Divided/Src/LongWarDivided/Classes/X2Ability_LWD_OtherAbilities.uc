 /////////////////////////////////////////////////////
//	For any classes with 3 or fewer new abilities	//
//////////////////////////////////////////////////////

class X2Ability_LWD_OtherAbilities extends TeddyXMBAbility
	config(LWD_SoldierSkills);

var localized string SmartlinkProtocolEffectName;
var localized string SmartlinkProtocolEffectDesc;

var config int GallopCooldown;
var config int FullyStockedBonusCharges;

var config int SelfAwareCooldown;
var config int SmartlinkProtocolAimBonus, SmartlinkProtocolCritBonus, SmartlinkProtocolCooldown;

var config int WhitesOfTheirEyesRange;

var config int DynamiteBonusRadius;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	// Artillery
	Templates.AddItem(AntiMateriel('LWD_AntiMateriel', "img:///UILibrary_LWD.ability_AntiMateriel"));
	Templates.AddItem(Gallop('LWD_Gallop', "img:///UILibrary_LWD.ability_Gallop"));
	Templates.AddItem(FullyStocked('LWD_FullyStocked', "img:///UILibrary_LWD.ability_FullyStocked"));
	// Assault
	Templates.AddItem(HandsAndFeet('LWD_HandsAndFeet', "img:///UILibrary_LWD.ability_handsandfeet"));
	// Combat Engineer
	Templates.AddItem(ArtificialIntelligence('LWD_ArtificialIntelligence', "img:///UILibrary_LWD.ability_ArtificialIntelligence"));
	Templates.AddItem(SelfAware('LWD_SelfAware', "img:///UILibrary_LWD.ability_SelfAware"));
	Templates.AddItem(SmartlinkProtocol('LWD_SmartlinkProtocol', "img:///UILibrary_LWD.ability_SmartlinkProtocol"));
	// Guerrilla
	Templates.AddItem(Jab('LWD_Jab', "img:///UILibrary_LWD.ability_jab"));
	Templates.AddItem(PurePassive('LWD_WhereItHurts', "img:///UILibrary_LWD.ability_whereithurts"));
	// Marksman
	Templates.AddItem(TightChoke('LWD_TightChoke', "img:///UILibrary_LWD.ability_tightchoke"));
	Templates.AddItem(WhitesOfTheirEyes('LWD_WhitesOfTheirEyes', "img:///UILibrary_LWD.ability_whitesoftheireyes"));
	Templates.AddItem(CloseRange('LWD_CloseRange', "img:///UILibrary_LWD.ability_DesignatedMarksman"));
	Templates.AddItem(CloseRangeShot('LWD_CloseRangeShot', "img:///UILibrary_PerkIcons.UIPerk_snipershot"));
	// Partisan
	Templates.AddItem(CattleProd('LWD_CattleProd', "img:///UILibrary_LWD.ability_cattleprod"));
	// Sapper
	Templates.AddItem(Dynamite('LWD_Dynamite', "img:///UILibrary_LWD.ability_Dynamite"));

	//Templates.AddItem(('LWD_', "img:///UILibrary_LWD.ability_"));

	return Templates;
}

static function X2AbilityTemplate AntiMateriel(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;	
	local XMBEffect_ConditionalBonus Effect;

	Effect = new class'XMBEffect_ConditionalBonus';

	Effect.AddArmorPiercingModifier(1, eHit_Success, 'conventional');
	Effect.AddArmorPiercingModifier(1, eHit_Success, 'laser_lw');
	Effect.AddArmorPiercingModifier(2, eHit_Success, 'magnetic');
	Effect.AddArmorPiercingModifier(2, eHit_Success, 'coilgun_lw');
	Effect.AddArmorPiercingModifier(2, eHit_Success, 'beam');

	Effect.AddShredModifier(1, eHit_Success, 'coilgun_lw');
	Effect.AddShredModifier(2, eHit_Success, 'beam');

	Effect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	Template = Passive(TemplateName, ImageIcon, true, Effect);

	return Template;
}//Anti-Materiel

static function X2AbilityTemplate Gallop(name TemplateName, string ImageIcon)
{
	local X2Effect_GrantActionPoints Effect;
	local X2AbilityTemplate Template;

	// Create an effect that will grant bonus action points
	Effect = new class'X2Effect_GrantActionPoints';

	// The effect grants three action points.
	Effect.NumActionPoints = 3;

	// Grant move action points, which can only be used for moving.
	Effect.PointType = class'X2CharacterTemplateManager'.default.MoveActionPoint;
	
	// Create the template as a helper function. This is an activated ability that doesn't cost an action.
	Template = SelfTargetActivated(TemplateName, ImageIcon, true, Effect, class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY, eCost_Double);

	AddCooldown(Template, default.GallopCooldown);

	return Template;
}//Gallop

static function X2AbilityTemplate FullyStocked(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate				Template;
	local X2Effect_BonusRocketChargesLW	RocketChargesEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);
	Template.IconImage = ImageIcon; 
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;

	RocketChargesEffect = new class 'X2Effect_BonusRocketChargesLW';
	RocketChargesEffect.BonusUses=default.FullyStockedBonusCharges;
	RocketChargesEffect.SlotType=eInvSlot_SecondaryWeapon;

	RocketChargesEffect.BuildPersistentEffect (1, true, false);
	RocketChargesEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (RocketChargesEffect);
	
	Template.bCrossClassEligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}//Fully Stocked

static function X2AbilityTemplate HandsAndFeet(name TemplateName, string ImageIcon)
{
	local X2Condition_AbilitySourceWeapon WeaponCondition;
	local X2AbilityTemplate Template;
	local X2Condition_UnitValue ValueCondition;
	local X2Effect_GrantActionPoints ActionPointEffect;
	local X2Effect_ImmediateAbilityActivation ReloadEffect;

	// Create a triggered ability that runs at the end of the player's turn
	Template = SelfTargetTrigger(TemplateName, ImageIcon, true, none, 'PlayerTurnEnded', eFilter_Player);

	// Trigger abilities don't appear as passives. Add a passive ability icon.
	AddIconPassive(Template);

	// Require clip not already full
	WeaponCondition = new class'X2Condition_AbilitySourceWeapon';
	WeaponCondition.WantsReload = true;
	Template.AbilityShooterConditions.AddItem(WeaponCondition);
	//AddTriggerShooterCondition(Template, WeaponCondition);

	// Require no attacks made this turn
	ValueCondition = new class'X2Condition_UnitValue';
	ValueCondition.AddCheckValue('NonMoveActionsThisTurn', 0, eCheck_Exact);
	Template.AbilityTargetConditions.AddItem(ValueCondition);

	// Reloading requires an action point, so grant one if the unit is out of action points
	ActionPointEffect = new class'X2Effect_GrantActionPoints';
	ActionPointEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	ActionPointEffect.NumActionPoints = 1;
	ActionPointEffect.bApplyOnlyWhenOut = true;
	AddSecondaryEffect(Template, ActionPointEffect);

	// Activate the Reload ability
	ReloadEffect = new class'X2Effect_ImmediateAbilityActivation';
	ReloadEffect.EffectName = 'ImmediateReload';
	ReloadEffect.AbilityName = 'Reload';
	ReloadEffect.BuildPersistentEffect(1, false, true, , eGameRule_PlayerTurnBegin);
	//ReloadEffect.VisualizationFn = EffectFlyOver_Visualization;
	AddSecondaryEffect(Template, ReloadEffect);

	Template.bShowActivation = true;

	Template.ActivationSpeech = 'Reloading';

	return Template;
}//Hands and Feet

static function X2AbilityTemplate ArtificialIntelligence(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local XMBEffect_AbilityCostRefund Effect;
	local XMBCondition_AbilityName AbilityNameCondition;
	
	// Create an effect that will refund the cost of attacks
	Effect = new class'XMBEffect_AbilityCostRefund';
	Effect.EffectName = 'ArtificialIntelligence';
	Effect.TriggeredEvent = 'ArtificialIntelligence';

	// Only refund once per turn
	Effect.CountValueName = 'ArtificialIntelligenceRefunds';
	Effect.MaxRefundsPerTurn = 1;

	// All the Gremlin abilities this applies to
	AbilityNameCondition = new class'XMBCondition_AbilityName';
	// New Abilities
	AbilityNameCondition.IncludeAbilityNames.AddItem('LWD_SmartlinkProtocol');
	// XCOM 2 Specialist Abilities
	AbilityNameCondition.IncludeAbilityNames.AddItem('FinalizeIntrusion');
	AbilityNameCondition.IncludeAbilityNames.AddItem('AidProtocol');
	AbilityNameCondition.IncludeAbilityNames.AddItem('CombatProtocol');
	AbilityNameCondition.IncludeAbilityNames.AddItem('GremlinHeal');
	AbilityNameCondition.IncludeAbilityNames.AddItem('GremlinStabilize');
	AbilityNameCondition.IncludeAbilityNames.AddItem('RevivalProtocol');
	AbilityNameCondition.IncludeAbilityNames.AddItem('CapacitorDischarge');
	AbilityNameCondition.IncludeAbilityNames.AddItem('RestorativeMist');
	AbilityNameCondition.IncludeAbilityNames.AddItem('ScanningProtocol');
	AbilityNameCondition.IncludeAbilityNames.AddItem('FinalizeHaywire');
	// LW2 Specialist Abilities
	AbilityNameCondition.IncludeAbilityNames.AddItem('FinalizeFullOverride');
	AbilityNameCondition.IncludeAbilityNames.AddItem('RescueProtocol');
	// Shadow Ops Dragoon Abilities
	AbilityNameCondition.IncludeAbilityNames.AddItem('ShadowOps_ShieldProtocol');
	AbilityNameCondition.IncludeAbilityNames.AddItem('ShadowOps_RestorationProtocol');
	AbilityNameCondition.IncludeAbilityNames.AddItem('ShadowOps_StealthProtocol');
	// Add it
	Effect.AbilityTargetConditions.AddItem(AbilityNameCondition);
	
	// Create the template using a helper function
	Template = Passive(TemplateName, ImageIcon, false, Effect);

	Template.bShowPostActivation = true;

	return Template;
}//Artificial Intelligence

static function X2AbilityTemplate SelfAware(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_ReduceCooldowns Effect;

	Effect = new class'X2Effect_ReduceCooldowns';
	Effect.ReduceAll = true;

	Template = SelfTargetActivated(TemplateName, ImageIcon, false, Effect, class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY, eCost_Free);

	AddCooldown(Template, default.SelfAwareCooldown);

	Template.bShowActivation = true;

	return Template;
}//Self Aware

static function X2AbilityTemplate SmartlinkProtocol(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate                     Template;
	local X2AbilityCost_ActionPoints            ActionPointCost;
	local X2Condition_UnitProperty              TargetProperty;
	local X2Condition_UnitEffects               EffectsCondition;
	local X2Effect_ThreatAssessment             CoveringFireEffect;
	local X2Condition_AbilityProperty           AbilityCondition;
	local X2Condition_UnitProperty              UnitCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, TemplateName);

	Template.IconImage = ImageIcon;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Defensive;
	Template.bLimitTargetIcons = true;
	Template.DisplayTargetHitChance = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	AddCooldown(Template, default.SmartlinkProtocolCooldown);

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SingleTargetWithSelf;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	TargetProperty.ExcludeHostileToSource = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	TargetProperty.RequireSquadmates = true;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect('SmartlinkProtocol', 'AA_UnitIsImmune');
	EffectsCondition.AddExcludeEffect('MimicBeaconEffect', 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	Template.AddTargetEffect(SmartlinkProtocolEffect());

	//  add covering fire effect if the soldier has threat assessment - this regular shot applies to all non-sharpshooters
	CoveringFireEffect = new class'X2Effect_ThreatAssessment';
	CoveringFireEffect.EffectName = 'ThreatAssessment_CF';
	CoveringFireEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);
	CoveringFireEffect.AbilityToActivate = 'OverwatchShot';
	CoveringFireEffect.ImmediateActionPoint = class'X2CharacterTemplateManager'.default.OverwatchReserveActionPoint;
	AbilityCondition = new class'X2Condition_AbilityProperty';
	AbilityCondition.OwnerHasSoldierAbilities.AddItem('ThreatAssessment');
	CoveringFireEffect.TargetConditions.AddItem(AbilityCondition);
	UnitCondition = new class'X2Condition_UnitProperty';
	UnitCondition.ExcludeHostileToSource = true;
	UnitCondition.ExcludeFriendlyToSource = false;
	UnitCondition.ExcludeSoldierClasses.AddItem('Sharpshooter');
	CoveringFireEffect.TargetConditions.AddItem(UnitCondition);
	Template.AddTargetEffect(CoveringFireEffect);

	//  add covering fire effect if the soldier has threat assessment - this pistol shot only applies to sharpshooters
	CoveringFireEffect = new class'X2Effect_ThreatAssessment';
	CoveringFireEffect.EffectName = 'PistolThreatAssessment';
	CoveringFireEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);
	CoveringFireEffect.AbilityToActivate = 'PistolReturnFire';
	CoveringFireEffect.ImmediateActionPoint = class'X2CharacterTemplateManager'.default.PistolOverwatchReserveActionPoint;
	AbilityCondition = new class'X2Condition_AbilityProperty';
	AbilityCondition.OwnerHasSoldierAbilities.AddItem('ThreatAssessment');
	CoveringFireEffect.TargetConditions.AddItem(AbilityCondition);
	UnitCondition = new class'X2Condition_UnitProperty';
	UnitCondition.ExcludeHostileToSource = true;
	UnitCondition.ExcludeFriendlyToSource = false;
	UnitCondition.RequireSoldierClasses.AddItem('Sharpshooter');
	CoveringFireEffect.TargetConditions.AddItem(UnitCondition);
	Template.AddTargetEffect(CoveringFireEffect);

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.bStationaryWeapon = true;
	Template.BuildNewGameStateFn = class'X2Ability_SpecialistAbilitySet'.static.AttachGremlinToTarget_BuildGameState;
	Template.BuildVisualizationFn = class'X2Ability_SpecialistAbilitySet'.static.GremlinSingleTarget_BuildVisualization;
	Template.bSkipPerkActivationActions = true;
	Template.bShowActivation = true;

	Template.CustomSelfFireAnim = 'NO_DefenseProtocol';

	return Template;
}//Smartlink Protocol

static function X2Effect_SmartlinkProtocol SmartlinkProtocolEffect()
{
	local X2Effect_SmartlinkProtocol                Effect;

	Effect = new class'X2Effect_SmartlinkProtocol';
	Effect.EffectName = 'SmartlinkProtocol';
	Effect.DuplicateResponse = eDupe_Ignore;            //  Gremlin effects should always be setup such that a target already under the effect is invalid.
	Effect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	Effect.bRemoveWhenTargetDies = true;
	Effect.SetDisplayInfo(ePerkBuff_Bonus, default.SmartlinkProtocolEffectName, default.SmartlinkProtocolEffectDesc, "img:///UILibrary_LWD.ability_SmartlinkProtocol", true);
	Effect.FriendlyName = "Smartlink";

	Effect.AimBonus = default.SmartlinkProtocolAimBonus;

	return Effect;
}//SmartlinkProtocolEffect

static function X2AbilityTemplate Jab(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_ApplyWeaponDamage DamageEffect;
	local X2AbilityToHitCalc_StandardMelee ToHitCalc;
	local X2Effect DisorientedEffect;
	local X2Condition_AbilityProperty AbilityCondition;

	DamageEffect = new class'X2Effect_ApplyWeaponDamage';
	// TTODO: Modify MeleeAttack to limit the range
	Template = LimitedMeleeAttack(TemplateName, ImageIcon, true, DamageEffect, class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY, eCost_Single, true, 0.5);

	ToHitCalc = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = ToHitCalc;

	// Got rid of this // Restrict the attack to units within X tiles
	//Template.AbilityTargetConditions.AddItem(TargetWithinTiles(default.JabRange));

	// Add disoriented effect...
	DisorientedEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect();
	// ...But only if the soldier has Where It Hurts.
	AbilityCondition = new class'X2Condition_AbilityProperty';
	AbilityCondition.OwnerHasSoldierAbilities.AddItem('LWD_WhereItHurts');
	DisorientedEffect.TargetConditions.AddItem(AbilityCondition);

	AddSecondaryEffect(Template, DisorientedEffect);

	return Template;
}//Jab

static function X2AbilityTemplate TightChoke(name TemplateName, string ImageIcon)
{
	local X2Effect_AdjustRangePenalty RangeEffect;
	local X2AbilityTemplate Template;
	local X2Condition_WeaponSlot Condition;

	RangeEffect = new class'X2Effect_AdjustRangePenalty';
	RangeEffect.Multiplier = -0.5;
	RangeEffect.FlatMod = 10;
	RangeEffect.PastMax = 4;
	RangeEffect.PastMaxFlatMod = 40;
	RangeEffect.bOnlyGood = true;

	Condition = new class'X2Condition_WeaponSlot';
	Condition.DesiredSlot = eInvSlot_SecondaryWeapon;
	Condition.WeaponCategory = 'sawedoffshotgun';

	RangeEffect.AbilityTargetConditions.AddItem(Condition);
	
	Template = Passive(TemplateName, ImageIcon, false, RangeEffect);

	return Template;
}//Tight Choke

static function X2AbilityTemplate WhitesOfTheirEyes(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2AbilityToHitCalc_StandardAim ToHit;
	local X2Condition_UnitProperty UnitPropertyCondition;

	// Create the template using a helper function
	Template = Attack(TemplateName, ImageIcon, false, none, class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY, eCost_None);
	
	// Reaction fire shouldn't show up as an activatable ability, it should be a passive instead
	HidePerkIcon(Template);
	AddIconPassive(Template);

	// Set the shot to be considered reaction fire
	ToHit = new class'X2AbilityToHitCalc_StandardAim';
	ToHit.bReactionFire = true;
	ToHit.bAllowCrit = true;
	Template.AbilityToHitCalc = ToHit;

	// Remove the default trigger of being activated by the player
	Template.AbilityTriggers.Length = 0;

	// Add a trigger that activates the ability on movement
	AddMovementTrigger(Template);

	// Add a trigger that activates the ability on attacks
	AddAttackTrigger(Template);

	// Restrict the shot to units within 4 tiles
	//Template.AbilityTargetConditions.AddItem(TargetWithinTiles(default.WhitesOfTheirEyesRange));
	UnitPropertyCondition = new class'X2Condition_UnitProperty';
	UnitPropertyCondition.RequireWithinRange = true;
	UnitPropertyCondition.WithinRange = `TILESTOUNITS(default.WhitesOfTheirEyesRange);
	Template.AbilityTargetConditions.AddItem(UnitPropertyCondition);

	// Since the attack has no cost, if we don't do anything else, it will be able to attack many
	// times per turn (until we run out of ammo). AddPerTargetCooldown uses an X2Effect_Persistent
	// that does nothing to mark our target unit, and a condition to prevent taking a second 
	// attack on a marked target in the same turn.
	AddPerTargetCooldown(Template, 1);

	return Template;
}//Whites of Their eyes

static function X2AbilityTemplate CloseRange(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect_AdjustRangePenalty CloseEffect;
	local X2Condition_WeaponSlot SniperCondition;

	CloseEffect = new class'X2Effect_AdjustRangePenalty';
	CloseEffect.Multiplier = -1;
	CloseEffect.FlatMod = 0;
	CloseEffect.WithinTiles = 14;
	CloseEffect.bOnlyGood = true;

	SniperCondition = new class'X2Condition_WeaponSlot';
	SniperCondition.DesiredSlot = eInvSlot_PrimaryWeapon;
	SniperCondition.WeaponCategory = 'sniper_rifle';

	CloseEffect.AbilityTargetConditions.AddItem(SniperCondition);
	
	Template = Passive(TemplateName, ImageIcon, false, CloseEffect);

	Template.AdditionalAbilities.AddItem('LWD_CloseRangeShot');

	return Template;
}//Close Range

static function X2AbilityTemplate CloseRangeShot(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate                 Template;	

	Template = Attack(TemplateName, ImageIcon, false, none, class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY, eCost_SingleConsumeAll, 1);

	Template.OverrideAbilities.AddItem('SniperStandardFire');

	return Template;	
}//CloseRangeShot

static function X2AbilityTemplate CattleProd(name TemplateName, string ImageIcon)
{
	local X2AbilityTemplate Template;
	local X2Effect Effect;
	local X2AbilityToHitCalc_StandardAim ToHitCalc;

	Effect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect();
	
	Template = LimitedMeleeAttack(TemplateName, ImageIcon, false, Effect, class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY, eCost_Single, true);

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	Template.AbilityToHitCalc = ToHitCalc;

	return Template;
}//Cattle Prod

static function X2AbilityTemplate Dynamite(name TemplateName, string ImageIcon)
{
	local XMBEffect_BonusRadius Effect;
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;

	Effect = new class'XMBEffect_BonusRadius';
	Effect.EffectName = 'Dynamite';
	Effect.fBonusRadius = default.DynamiteBonusRadius;
	Effect.IncludeItemNames.AddItem('ShapedCharge');

	Template = Passive(TemplateName, ImageIcon, true, Effect);

	ItemEffect = new class 'XMBEffect_AddUtilityItem';
	ItemEffect.DataName = 'ShapedCharge';
	AddSecondaryEffect(Template, ItemEffect);

	return Template;
}//Dynamite

//static function X2AbilityTemplate (name TemplateName, string ImageIcon)
//{
//	
//}