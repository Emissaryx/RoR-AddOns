namespace Game.Scripts.Dungeons.HuntersVale;

using Common.Enums;
using Game.NetWork.Handler;
using Game.World.Objects;

[GeneralScript(GameObjectEntry = 511)]
internal class ExitPortal : GameObjectScript
{
    public ExitPortal(GameObject gameObject)
        : base(gameObject) { }

    private int _mode;

    public override bool OnInteract(WorldObject obj, Player interactor, InteractMenu menu)
    {
        if (_mode != 0)
        {
            return false;
        }

        _mode = 1;
        _gameObject.VfxState = 5;

        _gameObject.Tasks.AddTask(
            () =>
            {
                _mode = 2;
                _gameObject.VfxState = 6;
                _gameObject.Tasks.AddTask(CheckActivationRange, 1000, 0);
            },
            3000,
            1
        );

        _gameObject.Tasks.AddTask(
            () =>
            {
                _mode = 3;
                _gameObject.VfxState = 7;
            },
            10000,
            1
        );

        _gameObject.Tasks.AddTask(
            () =>
            {
                _mode = 0;
                _gameObject.VfxState = 0;
                _gameObject.Tasks.RemoveTask(CheckActivationRange);
            },
            13000,
            1
        );

        return false;
    }

    private void CheckActivationRange()
    {
        foreach (Player plr in _gameObject.PlayersInRange)
        {
            if (!plr.IsDead && !plr.Stealth.IsInGameMasterStealth && _gameObject.IsWithin3DRadiusUnits(plr, 120))
            {
                if (plr.Realm == Realms.Order)
                {
                    plr.Teleport(207, 876156, 1331992, 8291, 3121);
                }
                else
                {
                    plr.Teleport(207, 845562, 1311278, 8341, 2865);
                }
            }
        }
    }
}
