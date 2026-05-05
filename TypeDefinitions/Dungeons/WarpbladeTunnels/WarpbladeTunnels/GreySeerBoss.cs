namespace WorldServer.World.Scripting.Dungeons.WarpbladeTunnels;

using Common.Enums.GameData;
using Common.Positions;
using WorldServer.World.Objects;

[GeneralScript(CreatureEntry = 2001371)]
internal class GreySeerBoss : BasicCreatureScript
{
    public GreySeerBoss(Unit unit)
        : base(unit)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        RemoveNpcFromRegion(2001389);
        RemoveNpcFromRegion(52595);

        obj.Tasks.RemoveTask(SpawnAddOnPlayer);

        AddInfluenceToAllPlayersInRegion(206, 1000);
        AddInfluenceToAllPlayersInRegion(207, 1000);

        DespawnCityDungeonWalls();

        base.OnDie(obj);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _unit.Tasks.AddTask(SpawnAddOnPlayer, 25 * 1000, 0);

        SpawnWarpblade1Walls();

        _unit.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        RemoveNpcFromRegion(2001389);
        RemoveNpcFromRegion(52595);

        _unit.Tasks.RemoveTask(SpawnAddOnPlayer);

        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.1 && _stageNum < 9 && !_unit.IsDead)
        {
            SpawnNpCs();

            _stageNum = 9;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.2 && _stageNum < 8 && !_unit.IsDead)
        {
            SpawnNpCs();

            _stageNum = 8;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.3 && _stageNum < 7 && !_unit.IsDead)
        {
            SpawnNpCs();

            _stageNum = 7;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.4 && _stageNum < 6 && !_unit.IsDead)
        {
            SpawnNpCs();

            _stageNum = 6;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.5 && _stageNum < 5 && !_unit.IsDead)
        {
            SpawnNpCs();

            _stageNum = 5;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.6 && _stageNum < 4 && !_unit.IsDead)
        {
            SpawnNpCs();

            _stageNum = 4;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.7 && _stageNum < 3 && !_unit.IsDead)
        {
            SpawnNpCs();

            _stageNum = 3;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.8 && _stageNum < 2 && !_unit.IsDead)
        {
            SpawnNpCs();

            _stageNum = 2;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.9 && _stageNum < 1 && !_unit.IsDead)
        {
            SpawnNpCs();

            _stageNum = 1;
        }
    }

    public void SpawnNpCs()
    {
        _adds.SpawnCreature(2001402, new Point3D(220409, 207192, 8185), 0); // Add

        _adds.SpawnCreature(2001402, new Point3D(220631, 208060, 7889), 0); // Add

        _adds.SpawnCreature(2001402, new Point3D(219813, 208494, 7884), 0); // Add

        _adds.SpawnCreature(2001402, new Point3D(219222, 208098, 7896), 0); // Add

        _adds.SpawnCreature(2001402, new Point3D(219226, 207456, 7939), 0); // Add

        _adds.SpawnCreature(2001402, new Point3D(219998, 207468, 7886), 0); // Add
    }

    public void SpawnAddOnPlayer()
    {
        Player? plr = GetRandomPlayerInRange();

        if (plr is not null)
        {
            _adds.SpawnCreature(52595, plr.WorldPosition, 0);
        }
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(2001389);
    }
}
