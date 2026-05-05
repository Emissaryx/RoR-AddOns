namespace Game.Scripts.Dungeons.Gunbad;

using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 38904)]
internal class RedeyeBigOaf : BasicScript
{
    public RedeyeBigOaf(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnDie(Unit obj)
    {
        DestroyWall();

        SpawnGoldChest(510); // This is Gunbad loot chest

        EndPublicQuest(510); // pq ID

        AddInfluenceToAllPlayersInRegion(64, 65, 800);

        base.OnDie(obj);
    }

    private void DestroyWall()
    {
        foreach (WorldObject? o in _unit.Region.Objects)
        {
            if (o is GameObject go && go.Entry == 100009)
            {
                go.Destroy();
            }
        }
    }
}
