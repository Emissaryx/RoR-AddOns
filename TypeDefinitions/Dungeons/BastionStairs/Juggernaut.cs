namespace Game.Scripts.Dungeons.BastionStairs;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;
using WarEmu.Database.World.Database.Maps;

[GeneralScript(CreatureEntry = 8530)]
internal class Juggernaut : BasicCreatureScript
{
    private readonly ZoneRepository _zoneRepository;

    public Juggernaut(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository,
        ZoneRepository zoneRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _zoneRepository = zoneRepository;
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(SpecialRage, 1000, 0);
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(43859);
        SetRandomTargetToNpc(49164);
    }

    public void SpecialRage()
    {
        Creature? c = GetCreatureFromRegion(49164);
        if (c is not null)
        {
            CheckDistanceAndHandleBuff(c, 13814, 480, "Blood Rage");
        }
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }

        if (_unit.Health.Value < _unit.Health.Total * 0.8 && _stageNum < 1 && !_unit.IsDead)
        {
            _stageNum = 1;
        }
    }

    public void CastBuffAndSpawnAdds()
    {
        byte i = 0;
        while (i < 100)
        {
            Player? plr = GetRandomPlayerInRange();
            if (plr is not null && plr != _unit.Targets.Get(TargetTypes.TARGETTYPES_TARGET_ENEMY))
            {
                _unit.Abilities.AddAbility(5694, plr, _unit.EffectiveLevel);
                break;
            }

            i++;
        }

        _adds.SpawnCreature(43859, new(026830, 996551, 14212), 0);
        _adds.SpawnCreature(43859, new(1027635, 996295, 14284), 0);
        _adds.SpawnCreature(43859, new(1027450, 996945, 14212), 0);
        _adds.SpawnCreature(43859, new(1026923, 996019, 14284), 0);
        _adds.SpawnCreature(43859, new(1026945, 997172, 14284), 0);
        _adds.SpawnCreature(43859, new(1027305, 996326, 14284), 0);
        _adds.SpawnCreature(43859, new(1027362, 996359, 14320), 0);

        _unit.Tasks.AddTask(CheckIfAnyNpcAround, 30 * 1000, 1);
    }

    public void CheckIfAnyNpcAround()
    {
        if (GetCreatureCountFromRegion(43859) > 0)
        {
            TeleportPlayer();
        }
        else
        {
            foreach (Player plr in _unit.Region.Players.ToList())
            {
                plr.Abilities.EndTargetAbilities(5694);
            }
        }
    }

    public void TeleportPlayer()
    {
        ZoneJump? zoneJump = null;

        switch (Random.Shared.Next(0, 2))
        {
            case 0:
                zoneJump = _zoneRepository.GetZoneJump(2225066);
                break;
            case 1:
                zoneJump = _zoneRepository.GetZoneJump(2225067);
                break;
        }

        if (zoneJump is not null)
        {
            foreach (Player plr in _unit.Region.Players.ToList())
            {
                if (
                    plr is not null
                    && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                    && !plr.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                    && !plr.IsDead
                    && !plr.Stealth.IsInGameMasterStealth
                    && plr.Abilities.HasBuffById(5694)
                )
                {
                    plr.Teleport(zoneJump.ZoneId, zoneJump.WorldX, zoneJump.WorldY, zoneJump.WorldZ, zoneJump.WorldO);
                    _unit.Abilities.AddAbility(5695, plr, _unit.EffectiveLevel);

                    break;
                }
            }
        }
    }
}
