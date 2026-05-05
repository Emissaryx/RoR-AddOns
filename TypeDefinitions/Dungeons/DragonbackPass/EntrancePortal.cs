namespace Game.Scripts.Dungeons.DragonbackPass;

using Common.Enums;
using Game.World.Instances;
using Game.World.Objects;

[GeneralScript(PortalEntry = 7041640)]
public class EntrancePortal : PortalScript
{
    private const uint OrderInstanceId = 36;
    private const uint DestructionInstanceId = 37;

    private readonly InstanceManager _instanceManager;

    public EntrancePortal(InstanceManager instanceManager)
    {
        _instanceManager = instanceManager;
    }

    public override bool OnZoneJump(Player plr, uint destinationId, byte responseType)
    {
        // If they are order handle the portal as normal
        if (plr.Realm == Realms.Order)
        {
            return true;
        }

        Guid guid = _instanceManager.GetInstanceId(plr, DestructionInstanceId);
        Instance? inInstance = _instanceManager.GetInstance(guid);
        inInstance?.AddPlayer(plr, 36, 205931, 357499, 7939, 1150);
        return false;
    }
}
