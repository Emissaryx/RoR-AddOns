namespace WorldServer.World.Scripting.Dungeons.BloodwroughtEnclave;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Common.Positions;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 2000751)]
internal class BarakusTheGodslayer : BasicCreatureScript
{
    public BarakusTheGodslayer(Unit unit)
        : base(unit)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.SpeedInterface.Speed = 400;
        _unit.Movement.SetBaseSpeed(_unit.SpeedInterface.Speed);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _unit.Tasks.AddTask(ApplyRage, 540 * 1000, 1);

        SpawnBloodwroughtWalls();

        _unit.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        _unit.Tasks.RemoveTask(ApplyRage);

        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        AddInfluenceToAllPlayersInRegion(200, 1000);
        AddInfluenceToAllPlayersInRegion(201, 1000);

        DespawnCityDungeonWalls();

        base.OnDie(obj);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.3 && _stageNum < 3 && !_unit.IsDead)
        {
            SendOnscreenMessageToAllPlayers("Barakus the God Slayer skin turned to iron!");

            _unit.Abilities.AddAbility(28500, _unit, _unit.EffectiveLevel);

            _stageNum = 3;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.5 && _stageNum < 2 && !_unit.IsDead)
        {
            SendOnscreenMessageToAllPlayers("Barakus the God Slayer summoned his Bloodletter servants!");

            // for some reason it returned null when trying to find spawn points, set a few manually for now
            // 10 adds total
            _adds.SpawnCreaturesAroundPos(46207, new Point3D(1570004, 1050049, 11129), 720, 2);
            _adds.SpawnCreaturesAroundPos(46207, new Point3D(1570144, 1050545, 11233), 720, 2);
            _adds.SpawnCreaturesAroundPos(46207, new Point3D(1569857, 1050554, 11233), 720, 2);
            _adds.SpawnCreaturesAroundPos(46207, new Point3D(1569621, 1050267, 11129), 720, 2);
            _adds.SpawnCreaturesAroundPos(46207, new Point3D(1570351, 1050235, 11129), 720, 2);

            _stageNum = 2;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.7 && _stageNum < 1 && !_unit.IsDead)
        {
            SendOnscreenMessageToAllPlayers("Barakus the God Slayer increased his power!");

            _unit.Abilities.AddAbility(22951, _unit, _unit.EffectiveLevel);

            _stageNum = 1;
        }
    }

    private void ApplyRage()
    {
        DelayedBuff(_unit, 5064, "Your time has come!"); // Rage
    }
}

[GeneralScript(CreatureEntry = 46207)]
internal class BarakusAdds : BasicCreatureScript
{
    public BarakusAdds(Unit unit)
        : base(unit)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.Disabled);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.Grapple);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.Knockdown);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.MoveImpedance);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.Root);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.Silence);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.Snare);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.Stagger);
        _unit.AddCrowdControlImmunity(CrowdControlTypes.Unstoppable);

        _unit.Tasks.AddTask(SayStuff, 15 * 1000, 1);

        // c.ScdInterface.AddTask(SayStuff2, 24000, 1);
        // c.ScdInterface.AddTask(c.Destroy, 25 * 1000, 1);
        _creature.Aggro.AggroResetDistance = 4800;
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc((int)GetTerrorCreature());
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        Player? target = ScriptHelpers.AddHatredToRandomPlayer(_creature, 500000);
        if (target is not null)
        {
            _creature.Say(target.Name + ", your skull is destined for the Throne of Skulls!", ChatLogFilter.Emote);
        }
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        DelayedBuff(_unit, 30001);

        base.OnEnterCombat(owner, attacker);
    }

    public override void SayStuff()
    {
        _unit.Say("Instability starts to affect the daemon...", ChatLogFilter.MonsterEmote);
    }

    public void SayStuff2()
    {
        _unit.Say("Instability claimed the daemon, it will fully evaporate in few moments...", ChatLogFilter.MonsterEmote);
    }
}
