namespace Game.Scripts.Dungeons.Gunbad;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 38623)]
internal class FoulMoufdaUngry : BasicScript
{
    public FoulMoufdaUngry(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnDie(Unit obj)
    {
        DestroyWall();
        SpawnGoldChest(510); // This is Gunbad loot chest

        EndPublicQuest(514);

        AddInfluenceToAllPlayersInRegion(64, 65, 800);

        base.OnDie(obj);
    }

    public void DestroyWall()
    {
        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 100005)
            {
                go.Destroy();
            }
        }
    }
}

[GeneralScript(CreatureEntry = 38633)]
internal class SlimespawnSquiglingsFoulMouf : BasicScript
{
    public SlimespawnSquiglingsFoulMouf(
        Unit unit,
        PQuestRepository pQuestRepository,
        GameObjectRepository gameObjectRepository
    )
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(SetRandomTarget, 200, 1);
    }
}
