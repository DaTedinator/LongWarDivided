//---------------------------------------------------------------------------------------
//  FILE:    XMBEffect_DoNotConsumeAllPoints.uc
//  AUTHOR:  xylthixlm
//
//  A persistent effect which causes a specific ability or abilities to not end the
//  turn when used as a first action.
//
//  EXAMPLES
//
//  The following examples in Examples.uc use this class:
//
//  BulletSwarm
//
//  INSTALLATION
//
//  Install the XModBase core as described in readme.txt. Copy this file, and any files 
//  listed as dependencies, into your mod's Classes/ folder. You may edit this file.
//
//  DEPENDENCIES
//
//  Core
//---------------------------------------------------------------------------------------
class XMBEffect_DoNotConsumeAllPoints extends X2Effect_Persistent implements(XMBEffectInterface);

//////////////////////
// Bonus properties //
//////////////////////

var array<name> AbilityNames;		// The abilities which will not end the turn as first action


////////////////////
// Implementation //
////////////////////

var bool HandledOnPostTemplatesCreated;

// From XMBEffectInterface
function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue) { return false; }
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, optional ShotBreakdown ShotBreakdown, optional out array<ShotModifierInfo> ShotModifiers) { return false; }

// From XMBEffectInterface
function bool GetExtValue(LWTuple Tuple)
{
	local name Ability;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityMgr;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local int i;

	if (Tuple.id != 'OnPostTemplatesCreated')
		return false;

	if (HandledOnPostTemplatesCreated)
		return false;

	AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	foreach AbilityNames(Ability)
	{
		AbilityTemplate = AbilityMgr.FindAbilityTemplate(Ability);
		if (AbilityTemplate == none)
		{
			`Log(EffectName $ ": Could not find ability template '" $ Ability $ "'");
			continue;
		}

		for (i = 0; i < AbilityTemplate.AbilityCosts.Length; i++)
		{
			ActionPointCost = X2AbilityCost_ActionPoints(AbilityTemplate.AbilityCosts[i]);
			if (ActionPointCost != none && ActionPointCost.DoNotConsumeAllEffects.Find(EffectName) == INDEX_NONE)
			{
				// Action point costs may be shared between effects. We don't want to accidentally modify a shared
				// object, so make a copy.
				ActionPointCost = new ActionPointCost.class(ActionPointCost);
				AbilityTemplate.AbilityCosts[i] = ActionPointCost;
					
				ActionPointCost.DoNotConsumeAllEffects.AddItem(EffectName);
			}
		}
	}

	HandledOnPostTemplatesCreated = true;
	return true;
}
