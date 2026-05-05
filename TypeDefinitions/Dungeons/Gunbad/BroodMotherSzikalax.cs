namespace Game.Scripts.Dungeons.Gunbad;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 36608)]
internal class BroodMotherSzikalax : BasicScript
{
    public BroodMotherSzikalax(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        SetInvisible("Invisible Creature");

        _unit.RespectLoS = false;
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        SetVisible(_unit.Name, 1380);

        _unit.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;

        _unit.Tasks.AddTask(SpawnSpiders, 30 * 1000, 0);
    }

    private void SpawnSpiders()
    {
        _adds.SpawnCreature(2000904, new(844260, 857649, 28536), _unit.Heading);
        _adds.SpawnCreature(2000904, new(844260, 857649, 28536), _unit.Heading);
        _adds.SpawnCreature(2000904, new(844260, 857649, 28536), _unit.Heading);
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);

        if (!_unit.IsDead)
        {
            SetInvisible("Invisible Creature");
        }

        _unit.Tasks.RemoveTask(SpawnSpiders);
    }

    public override void OnDie(Unit obj)
    {
        base.OnDie(obj);

        _unit.Tasks.RemoveTask(SpawnSpiders);

        AddInfluenceToAllPlayersInRegion(64, 65, 800);
    }
}

[GeneralScript(CreatureEntry = 36597)]
internal class SpiderBroodMotherSzikalax : BasicScript
{
    public SpiderBroodMotherSzikalax(
        Unit unit,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        SetInvisible("Invisible Creature");
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        SetVisible(_unit.Name, 1379);

        _unit.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);

        if (!_unit.IsDead)
        {
            SetInvisible("Invisible Creature");
        }
    }
}

[GeneralScript(CreatureEntry = 2000904)]
internal class SpiderAddBroodMotherSzikalax : BasicScript
{
    public SpiderAddBroodMotherSzikalax(
        Unit unit,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        SetInvisible("Invisible Creature");

        obj.Tasks.AddTask(SetRandomTarget, 200, 1);
    }

    public override void OnEnterCombat(Unit owner, Unit? attacker)
    {
        SetVisible(owner.Name, 1379);

        owner.DormantInfo &= ~DormantFlags.CannotBeTargeted & ~DormantFlags.CannotBeAttacked;
        _stageNum = -1;
    }

    public override void OnLeaveCombat(Unit owner)
    {
        base.OnLeaveCombat(owner);

        if (!owner.IsDead)
        {
            SetInvisible("Invisible Creature");
        }
    }
}
