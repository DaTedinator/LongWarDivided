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
	Templates.AddItem(FullyStocked('LWD_', "img:///UILibrary_LWD.ability_FullyStocked"));
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
	local XMBEffect_AddAbilityCharges RocketChargesEffect;
	local X2AbilityTemplate Template;

	RocketChargesEffect = new class 'XMBEffect_AddAbilityCharges';
	RocketChargesEffect.AbilityNames.AddItem('LWRocketLauncher');
	RocketChargesEffect.AbilityNames.AddItem('LWBlasterLauncher');
	RocketChargesEffect.BonusCharges = default.FullyStockedBonusCharges;

	Template = Passive(TemplateName, ImageIcon, false, none);

	AddSecondaryEffect(Template, RocketChargesEffect);

	return Template;
}//Fully Stocked

static function X2AbilityTemplate HandsAndFeet(name TemplateName, string ImageIcon)
{
	local X2Condition_AbilitySourceWeapon WeaponCondition;
	local X2AbilityTemplate Template;
	local X2Condition_UnitValue ValueCondition;

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

//	// Reloading requires an action point, so grant one if the unit is out of action points
//	ActionPointEffect = new class'X2Effect_GrantActionPoints';
//	ActionPointEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
//	ActionPointEffect.NumActionPoints = 1;
//	ActionPointEffect.bApplyOnlyWhenOut = true;
//	AddSecondaryEffect(Template, ActionPointEffect);

//	// Activate the Reload ability
//	ReloadEffect = new class'X2Effect_ImmediateAbilityActivation';
//	ReloadEffect.EffectName = 'ImmediateReload';
//	ReloadEffect.AbilityName = 'Reload';
//	ReloadEffect.BuildPersistentEffect(1, false, true, , eGameRule_PlayerTurnBegin);
//	AddSecondaryEffect(Template, ReloadEffect);

	Template.bShowActivation = true;

	Template.ActivationSpeech = 'Reloading';

	Template.BuildNewGameStateFn = HandsAndFeetAbility_BuildGameState;
	Template.BuildVisualizationFn = HandsAndFeetAbility_BuildVisualization;

	return Template;
}//Hands and Feet

simulated function XComGameState HandsAndFeetAbility_BuildGameState( XComGameStateContext Context )
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability AbilityState;
	local XComGameState_Item WeaponState, NewWeaponState;

	NewGameState = `XCOMHISTORY.CreateNewGameState(true, Context);	
	AbilityContext = XComGameStateContext_Ability(Context);	
	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID( AbilityContext.InputContext.AbilityRef.ObjectID ));

	WeaponState = AbilityState.GetSourceWeapon();
	NewWeaponState = XComGameState_Item(NewGameState.CreateStateObject(class'XComGameState_Item', WeaponState.ObjectID));

	UnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', AbilityContext.InputContext.SourceObject.ObjectID));	

	AbilityState.GetMyTemplate().ApplyCost(AbilityContext, AbilityState, UnitState, NewWeaponState, NewGameState);	

	//  refill the weapon's ammo	
	NewWeaponState.Ammo = NewWeaponState.GetClipSize();
	
	NewGameState.AddStateObject(UnitState);
	NewGameState.AddStateObject(NewWeaponState);

	return NewGameState;	
}//HandsAndFeetAbility_BuildGameState

simulated function HandsAndFeetAbility_BuildVisualization(XComGameState VisualizeGameState, out array<VisualizationTrack> OutVisualizationTracks)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  Context;
	local StateObjectReference          ShootingUnitRef;	
	local X2Action_PlayAnimation		PlayAnimation;

	local VisualizationTrack        EmptyTrack;
	local VisualizationTrack        BuildTrack;

	local XComGameState_Ability Ability;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyover;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	ShootingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	BuildTrack = EmptyTrack;
	BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(ShootingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(ShootingUnitRef.ObjectID);
	BuildTrack.TrackActor = History.GetVisualizer(ShootingUnitRef.ObjectID);
					
	PlayAnimation = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTrack(BuildTrack, Context));
	PlayAnimation.Params.AnimName = 'HL_Reload';

	Ability = XComGameState_Ability(History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID));
	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTrack(BuildTrack, Context));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, "", Ability.GetMyTemplate().ActivationSpeech, eColor_Good);

	OutVisualizationTracks.AddItem(BuildTrack);
	//****************************************************************************************
}//HandsAndFeetAbility_BuildVisualization

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
	Effect.SetDisplayInfo(ePerkBuff_Bonus, default.SmartlinkProtocolEffectName, default.SmartlinkProtocolEffectDesc, "img:///UILibrary_LWD2.ability_SmartlinkProtocol", true);
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
	local X2Condition_UnitInventory Condition;

	RangeEffect = new class'X2Effect_AdjustRangePenalty';
	RangeEffect.Multiplier = -0.5;
	RangeEffect.FlatMod = 10;
	RangeEffect.PastMax = 4;
	RangeEffect.PastMaxFlatMod = 40;
	RangeEffect.bOnlyGood = true;

	Condition = new class'X2Condition_UnitInventory';
	Condition.RelevantSlot = eInvSlot_SecondaryWeapon;

	RangeEffect.TargetConditions.AddItem(Condition);
	
	Template = Passive(TemplateName, ImageIcon, false, RangeEffect);

	return Template;
}//Tight Choke

// TTODO: Consider whether to add aim bonus to these attacks/get rid of range penalties
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