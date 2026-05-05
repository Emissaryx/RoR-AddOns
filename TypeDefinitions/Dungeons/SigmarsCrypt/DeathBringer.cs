namespace Game.Scripts.Dungeons.SigmarsCrypt;

using Common.Enums.GameData;
using Game.Repositories.World;
using Game.World.Objects;

[GeneralScript(CreatureEntry = 2001363)]
internal class DeathBringer : BasicScript
{
    public DeathBringer(Unit unit, PQuestRepository pQuestRepository, GameObjectRepository gameObjectRepository)
        : base(unit, pQuestRepository, gameObjectRepository) { }

    public override void OnObjectLoad(WorldObject obj)
    {
        base.OnObjectLoad(obj);

        obj.Tasks.AddTask(ClearImmunities, 900, 0);

        if (obj is Creature c)
        {
            c.Aggro.AggroResetDistance = 400;
            c.ApplySpeedBuffOnReset = false;
        }

        obj.Tasks.AddTask(SetRandomTarget, 200, 1);
        obj.Tasks.AddTask(SetRandomTarget, 30 * 1000, 0);
    }

    public override void SetRandomTarget()
    {
        if (_unit.PlayersInRange.Count > 0)
        {
            int playersInRange = _unit.PlayersInRange.Count;
            Player? player;
            byte i = 0;
            while (i < 15)
            {
                int rndmPlr = Random.Shared.Next(1, playersInRange + 1);
                WorldObject obj = _unit.PlayersInRange.ElementAt(rndmPlr - 1);
                player = obj as Player;
                if (
                    player is not null
                    && !player.IsDead
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeTargeted)
                    && !player.DormantInfo.HasFlag(DormantFlags.CannotBeAttacked)
                )
                {
                    _unit.Movement.TurnTo(player);
                    _unit.Speed.SetBaseSpeed(70);
                    _unit.Movement.Follow(player, 60, 120);
                    break;
                }

                i++;
            }
        }
    }
}
