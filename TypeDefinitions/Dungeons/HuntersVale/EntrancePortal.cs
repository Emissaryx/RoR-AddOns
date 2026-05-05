namespace Game.Scripts.Dungeons.HuntersVale;

using Common.Enums;
using Common.Enums.GameData;
using Common.Enums.SystemData;
using Game.NetWork.Handler;
using Game.World.Instances;
using Game.World.Objects;

internal class EntrancePortal : GameObjectScript
{
    private readonly InstanceManager _instanceManager;

    public EntrancePortal(GameObject gameObject, Realms realm, InstanceManager instanceManager)
        : base(gameObject)
    {
        _realm = realm;
        _instanceManager = instanceManager;
    }

    private int _mode;
    private readonly Realms _realm;

    public override bool OnInteract(WorldObject obj, Player player, InteractMenu menu)
    {
        if (player.Realm != _realm)
        {
            _gameObject.PlaySound(1461); // s_Kurnous_VO_PQ_17
            player.Abilities.AddAbility(24619, player, player.EffectiveLevel);

            return false;
        }

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

        return true;
    }

    private void CheckActivationRange()
    {
        foreach (Player plr in _gameObject.PlayersInRange)
        {
            if (!plr.IsDead && !plr.Stealth.IsInGameMasterStealth && _gameObject.IsWithin3DRadiusUnits(plr, 120))
            {
                Guid guid = _instanceManager.GetInstanceId(plr, 50);
                Instance? inInstance = _instanceManager.GetInstance(guid);
                if (!inInstance?.AddPlayer(plr, 50, 316304, 528074, 4328, 2984) ?? false)
                {
                    plr.SendLocalizeString(
                        string.Empty,
                        ChatLogFilter.UserError,
                        LocalizedText.TEXT_PLAYER_REGION_NOT_AVAILABLE
                    );
                }
            }
        }
    }
}

[GeneralScript(GameObjectEntry = 20020153)]
internal class OrderEntrancePortal : EntrancePortal
{
    public OrderEntrancePortal(GameObject gameObject, InstanceManager instanceManager)
        : base(gameObject, Realms.Order, instanceManager) { }
}

[GeneralScript(GameObjectEntry = 20020154)]
internal class DestroEntrancePortal : EntrancePortal
{
    public DestroEntrancePortal(GameObject gameObject, InstanceManager instanceManager)
        : base(gameObject, Realms.Destruction, instanceManager) { }
}
