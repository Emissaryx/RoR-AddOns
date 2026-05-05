namespace Game.Scripts.Dungeons.BilerotBurrow;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 52595)]
internal class DiseasedGround : BasicCreatureScript
{
    public DiseasedGround(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        _creature.Aggro.SendAggroUpdate = false;
    }

    public override void OnEnterWorld(WorldObject obj)
    {
        DelayedBuff(_creature, 4388); // Taunt Immunity
    }
}
