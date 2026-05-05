namespace Game.Scripts.Dungeons.SigmarsCrypt;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;
using WarEmu.Database.World.Database.Creatures;

[GeneralScript(CreatureEntry = 2001245)]
internal class Malcidious : BasicCreatureScript
{
    public Malcidious(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 2220;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        _unit.AddCrowdControlImmunity(CrowdControlTypes.All);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _unit.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        _unit.Tasks.AddTask(SpawnPlayerSpirit, 100, 1);
        _unit.Tasks.AddTask(SpawnPlayerSpirit, 30 * 1000, 0);

        byte i = 0;
        byte j = 0;
        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is Creature crea)
            {
                if (crea.Entry == 52379 && !crea.IsDead)
                {
                    i++;
                    continue;
                }

                if (crea.Entry == 3221 && !crea.IsDead)
                {
                    j++;
                }
            }
        }

        if (i > 0)
        {
            _unit.Say("Come, my minions! Those fools thought they can bypas my allies!", ChatLogFilter.MonsterSay);
            _adds.SpawnCreaturesAroundPos(52379, _unit.WorldSpawnPoint, 300);
        }

        if (j > 0)
        {
            if (i == 0)
            {
                _unit.Say("Come, my minions! Those fools thought they can bypas my allies!", ChatLogFilter.MonsterSay);
            }

            _adds.SpawnCreaturesAroundPos(3221, _unit.WorldSpawnPoint, 300);
        }

        SpawnSigmarsCryptWalls();

        _unit.Tasks.AddTask(TerminateSoloPlayers, 1000, 0);
    }

    public void SpawnPlayerSpirit()
    {
        Player? target = _unit.PlayersInRange.FirstOrDefault(plr =>
            !plr.IsDead
            && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
            && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
            && !plr.Stealth.IsInGameMasterStealth
        );

        if (target is not null)
        {
            CreatureProto? proto = CreatureProtoRepository.Instance.GetCreatureProto(2001358);
            if (proto is null)
            {
                return;
            }

            Creature c = Creature.Create(Global.ServiceProvider, proto);
            c.NoRespawn = true;
            c.Name = $"{target.Name}'s Spirit";

            _adds.Add(c, target.WorldPosition, target.Heading);
        }
    }

    public override void OnRemoveFromWorld(WorldObject obj)
    {
        OnDie(_unit);
        base.OnRemoveFromWorld(obj);
    }

    public override void OnDie(Unit obj)
    {
        obj.Tasks.RemoveTask(SpawnPlayerSpirit);
        obj.Tasks.RemoveTask(SpawnPlayerSpirit);

        foreach (Player plr in obj.Region.Players.ToList())
        {
            if (plr is not null)
            {
                plr.Abilities.EndTargetAbilities(13633); // Removing gimp buff
            }
        }

        DespawnCityDungeonWalls();

        base.OnDie(obj);
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.2 && _stageNum < 3 && !_unit.IsDead)
        {
            _unit.Tasks.RemoveTask(SpawnPlayerSpirit);
            _unit.Tasks.RemoveTask(SpawnPlayerSpirit);

            _unit.Say("You shall Know Death!", ChatLogFilter.MonsterSay);

            // Death Bringer
            _adds.SpawnCreature(2001363, new(1504636, 213669, 8228), 10);

            // Death Bringer
            _adds.SpawnCreature(2001363, new(1504532, 213669, 8228), 10);

            _stageNum = 3;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.4 && _stageNum < 2 && !_unit.IsDead)
        {
            _adds.SpawnCreaturesAroundPos(2001362, _unit.WorldPosition, 360, 6);

            _stageNum = 2;
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.6 && _stageNum < 1 && !_unit.IsDead)
        {
            foreach (Player plr in _unit.PlayersInRange)
            {
                if (
                    plr is not null
                    && !plr.IsDead
                    && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                    && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                    && !plr.Stealth.IsInStealth
                )
                {
                    // Add
                    _adds.SpawnCreaturesAroundPos(2001361, _unit.WorldPosition, 360);
                }
            }

            _stageNum = 1;
        }
    }

    public override void OnLeaveCombat(Unit owner)
    {
        _unit.Tasks.RemoveTask(SpawnPlayerSpirit);
        _unit.Tasks.RemoveTask(SpawnPlayerSpirit);

        DespawnCityDungeonWalls();

        base.OnLeaveCombat(owner);
    }
}

[GeneralScript(CreatureEntry = 2001358)]
internal class PlayerSpirit : BasicScript
{
    public PlayerSpirit(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);
    }
}
