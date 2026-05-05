namespace WorldServer.World.Scripting.Dungeons.LostVale;

using Common.Enums.GameData;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 6843)]
internal class ButcherGutbearer : BasicCreatureScript
{
    private readonly ILogger<ButcherGutbearer> _logger;

    public ButcherGutbearer(ILogger<ButcherGutbearer> logger, Unit unit)
        : base(unit)
    {
        _logger = logger;
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        if (_unit.Zone == null)
        {
            _logger.LogError(new InvalidOperationException("Zone is null"), "Zone is null for {Unit}", _unit);
            return;
        }

        _adds.SpawnCreaturesAroundPos(6816, _unit.WorldSpawnPoint, 300);

        _unit.Tasks.AddTask(CheckForGnoblar, 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    public void CheckForGnoblar()
    {
        if (_unit.Zone == null)
        {
            _logger.LogError(new InvalidOperationException("Zone is null"), "Zone is null for {Unit}", _unit);
            return;
        }

        if (_unit is Creature c && !c.IsDead && c.CombatFlag.IsInCombat)
        {
            Creature? crea = GetCreatureFromRegion(6816);
            if (crea is null)
            {
                _adds.SpawnCreaturesAroundPos(6816, _unit.WorldPosition, 300);
            }
        }
    }

    public override void OnLeaveCombat(Unit owner)
    {
        ClearStuff();

        base.OnLeaveCombat(owner);
    }

    public override void OnDie(Unit obj)
    {
        ClearStuff();

        base.OnDie(obj);
    }

    public void ClearStuff()
    {
        _unit.Tasks.RemoveTask(CheckForGnoblar);

        if (_unit.Region == null)
        {
            _logger.LogError(new InvalidOperationException("Region is null"), "Region is null for {Unit}", _unit);
            return;
        }

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is Creature crea && crea.Entry == 6816)
            {
                crea.Destroy();
            }
        }

        _unit.Abilities.EndTargetAbilities((ushort)13669);
    }
}

[GeneralScript(CreatureEntry = 6816)]
internal class GutbearerGnoblar : BasicScript
{
    public GutbearerGnoblar(Unit unit)
        : base(unit)
    {
    }

    public override void OnDie(Unit obj)
    {
        Creature? boss = GetCreatureFromRegion(6843);

        if (boss is not null && !boss.IsDead)
        {
            boss.Abilities.AddAbility(13669, boss, boss.EffectiveLevel);
        }

        base.OnDie(obj);
    }
}
