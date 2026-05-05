namespace Game.Scripts.Dungeons.BastionStairs;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 47438)]
internal class Burlok : BasicCreatureScript
{
    public Burlok(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository)
    {
        _creature.Enrage.EnableRangeUnits = 1620;
    }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);
        _creature.Aggro.AggroResetDistance = 3600;
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(2000670);
    }
}

[GeneralScript(CreatureEntry = 2000670)]
internal class Squonk : BasicCreatureScript
{
    public Squonk(Creature creature, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(creature, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);
        _creature.Aggro.AggroResetDistance = 3600;
    }

    public override void OnDealDamage(Unit obj, Unit target, uint damage)
    {
        SetRandomTargetToNpc(47438);
    }
}
