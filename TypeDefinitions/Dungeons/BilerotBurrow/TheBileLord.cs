namespace Game.Scripts.Dungeons.BilerotBurrow;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 52594)]
internal class TheBileLord : BasicCreatureScript
{
    public TheBileLord(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1820;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _unit.Tasks.AddTask(SpawnAddOnPlayer, TimeSpan.FromSeconds(25), 0);

        SpawnBilerotWalls();

        _unit.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);

        base.OnEnterCombat(owner, attacker);
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(SpawnAddOnPlayer);
        RemoveNpcFromRegion(52595);

        DespawnCityDungeonWalls();

        base.OnDie(obj);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        _unit.Tasks.RemoveTask(SpawnAddOnPlayer);
        RemoveNpcFromRegion(52595);

        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }

    public void SpawnAddOnPlayer()
    {
        Player? plr = GetRandomPlayerInRange();

        if (plr is not null)
        {
            _adds.SpawnCreature(52595, plr.WorldPosition, 0);
        }
    }

    private void TeleportPlayerToGut()
    {
        int i = 0;
        foreach (Player plr in _unit.PlayersInRange)
        {
            if (
                !plr.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                && !plr.IsDead
                && !plr.Stealth.IsInGameMasterStealth
            )
            {
                _creature.Tasks.AddTask(
                    () =>
                    {
                        plr.IntraRegionTeleport(
                            1493955 + (uint)Random.Shared.Next(1, 50),
                            1055596 + (uint)Random.Shared.Next(1, 50),
                            14633,
                            1752
                        );
                    },
                    ++i * 500,
                    1
                );
            }
        }
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.19 && _stageNum < 5 && !_unit.IsDead)
        {
            _stageNum = 5;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.2 && _stageNum < 4 && !_unit.IsDead)
        {
            foreach (Player plr in obj.Region.Players.ToList())
            {
                _unit.Abilities.AddAbility(13700, plr, _unit.EffectiveLevel);
            }

            _unit.Speed.SetBaseSpeed(0);

            _unit.AbilityCast.StartCast(13933, 0);

            _adds.SpawnCreature(2000725, new(1493910, 1055318, 14544), 2721);

            _unit.Tasks.AddTask(TeleportPlayerToGut, 2100, 1);
            _unit.Tasks.AddTask(
                () => SendOnscreenMessageToAllPlayers("Bile Lord swallowed you and your companions!"),
                3100,
                1
            );

            _unit.PlayEffect(2189);

            _stageNum = 4;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.4 && _stageNum < 3 && !_unit.IsDead)
        {
            SendOnscreenMessageToAllPlayers("The Bile Lord calls for his children of filth");

            _adds.SpawnCreature(2001378, new(1501826, 1047742, 11398), 3993);

            _adds.SpawnCreature(2001378, new(1500296, 1047906, 11410), 4004);

            _adds.SpawnCreature(2001378, new(1498645, 1047621, 11398), 3720);

            _adds.SpawnCreature(2001378, new(1498864, 1050362, 11598), 2377);

            _adds.SpawnCreature(2001378, new(1500415, 1050706, 11954), 2059);

            _adds.SpawnCreature(2001378, new(1502141, 1049405, 11568), 1479);

            _stageNum = 3;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.6 && _stageNum < 2 && !_unit.IsDead)
        {
            SendOnscreenMessageToAllPlayers("The Bile Lord calls for his children of filth");

            _adds.SpawnCreature(2000724, new(1501826, 1047742, 11398), 3993);

            _adds.SpawnCreature(2000724, new(1500296, 1047906, 11410), 4004);

            _adds.SpawnCreature(2000724, new(1498645, 1047621, 11398), 3720);

            _adds.SpawnCreature(2000724, new(1498864, 1050362, 11598), 2377);

            _adds.SpawnCreature(2000724, new(1500415, 1050706, 11954), 2059);

            _adds.SpawnCreature(2000724, new(1502141, 1049405, 11568), 1479);

            _stageNum = 2;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.8 && _stageNum < 1 && !_unit.IsDead)
        {
            SendOnscreenMessageToAllPlayers("The Bile Lord calls for his children of filth");

            _adds.SpawnCreature(2001379, new(1501826, 1047742, 11398), 3993);

            _adds.SpawnCreature(2001379, new(1500296, 1047906, 11410), 4004);

            _adds.SpawnCreature(2001379, new(1498645, 1047621, 11398), 3720);

            _adds.SpawnCreature(2001379, new(1498864, 1050362, 11598), 2377);

            _adds.SpawnCreature(2001379, new(1500415, 1050706, 11954), 2059);

            _adds.SpawnCreature(2001379, new(1502141, 1049405, 11568), 1479);

            _stageNum = 1;
        }
    }

    public void RemoveImmunities()
    {
        _unit.RemoveCrowdControlImmunity((int)CrowdControlTypes.All);
    }

    public override void OnWorldUpdate(WorldObject obj, long tick)
    {
        // Make sure we stay in combat as long as adds are in combat (innards especially)
        foreach (Unit add in _adds.GetUnits())
        {
            _unit.CombatFlag.SetCombatTimerTo(add);
        }
    }
}
