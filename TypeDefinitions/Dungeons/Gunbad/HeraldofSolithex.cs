namespace Game.Scripts.Dungeons.Gunbad;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 37964)]
internal class HeraldofSolithex : BasicScript
{
    public HeraldofSolithex(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _unit.RespectLoS = false;
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        _unit.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        SetRandomTargetToNpc(2000893); // Logazor join fight
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(2000893); // Checking for Logazor
    }

    public override void OnReceiveDamage(Unit obj, Unit attacker, uint damage)
    {
        if (_stageNum < 0 && !_unit.IsDead)
        {
            _stageNum = 0; // Setting control value to 0
        }
        else if (_unit.Health.Value < _unit.Health.Total * 0.5 && _stageNum < 1 && !_unit.IsDead)
        {
            _unit.Say(
                "Rise, my royal servant! Protect those mains from those who want to steal them from you!",
                ChatLogFilter.MonsterSay
            );

            _adds.SpawnCreature(2000893, new(843373, 861016, 25691), _unit.Heading); // Logazor

            _stageNum = 1;
        }
    }

    public override void OnDie(Unit obj)
    {
        DestroyWall();
        SpawnGoldChest(510); // This is Gunbad loot chest

        EndPublicQuest(515);

        AddInfluenceToAllPlayersInRegion(64, 65, 800);

        base.OnDie(obj);
    }

    public void DestroyWall()
    {
        if (_unit.Region is null)
        {
            return;
        }

        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject { Entry: 100008 } go)
            {
                go.Destroy();
            }
        }
    }
}
