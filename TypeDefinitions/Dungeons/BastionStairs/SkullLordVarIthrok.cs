namespace Game.Scripts.Dungeons.BastionStairs;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 64106)]
internal class SkullLordVarIthrok : BasicCreatureScript
{
    public SkullLordVarIthrok(
        Creature creature,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1200;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);
        _creature.Aggro.AggroResetDistance = 3000;
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_creature.IsDead)
        {
            return;
        }

        if (_creature.Health.Value < _creature.Health.Total * 0.02 && _stageNum < 20)
        {
            _stageNum = 20;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.05 && _stageNum < 19)
        {
            SpawnNPCOnPlayer();

            _stageNum = 19;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.1 && _stageNum < 18)
        {
            SpawnNPCOnPlayer();

            _stageNum = 18;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.15 && _stageNum < 17)
        {
            SpawnNPCOnPlayer();

            _stageNum = 17;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.2 && _stageNum < 16)
        {
            SpawnNPCOnPlayer();

            _stageNum = 16;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.25 && _stageNum < 15)
        {
            SpawnNPCOnPlayer();

            _stageNum = 15;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.3 && _stageNum < 14)
        {
            SpawnNPCOnPlayer();

            _stageNum = 14;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.35 && _stageNum < 13)
        {
            SpawnNPCOnPlayer();

            _stageNum = 13;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.4 && _stageNum < 12)
        {
            SpawnNPCOnPlayer();

            _stageNum = 12;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.45 && _stageNum < 11)
        {
            SpawnNPCOnPlayer();

            _stageNum = 11;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.5 && _stageNum < 10)
        {
            SpawnNPCOnPlayer();

            _stageNum = 10;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.55 && _stageNum < 9)
        {
            SpawnNPCOnPlayer();

            _stageNum = 9;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.6 && _stageNum < 8)
        {
            SpawnNPCOnPlayer();

            _stageNum = 8;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.65 && _stageNum < 7)
        {
            SpawnNPCOnPlayer();

            _stageNum = 7;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.7 && _stageNum < 6)
        {
            SpawnNPCOnPlayer();

            _stageNum = 6;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.75 && _stageNum < 5)
        {
            SpawnNPCOnPlayer();

            _stageNum = 5;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.8 && _stageNum < 4)
        {
            SpawnNPCOnPlayer();

            _stageNum = 4;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.85 && _stageNum < 3)
        {
            SpawnNPCOnPlayer();

            _stageNum = 3;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.9 && _stageNum < 2)
        {
            SpawnNPCOnPlayer();

            _stageNum = 2;
        }
        else if (_creature.Health.Value < _creature.Health.Total * 0.95 && _stageNum < 1 && !_creature.IsDead)
        {
            SpawnNPCOnPlayer();

            _stageNum = 1;
        }
    }

    public void SpawnNPCOnPlayer()
    {
        Player? plr = GetRandomPlayerInRange();

        if (plr is null)
        {
            return;
        }

        // Spawn static creature
        _adds.SpawnCreaturesAroundPos(39451, plr.WorldPosition, 300, 2);
    }

    public override void OnDie(Unit obj)
    {
        if (obj is not Creature c)
        {
            return;
        }

        c.Movement.TurnTo(0);

        //AddInfluenceToAllPlayersInRegion(128, 2000);
        //AddInfluenceToAllPlayersInRegion(129, 2000);

        base.OnDie(obj);
    }
}
