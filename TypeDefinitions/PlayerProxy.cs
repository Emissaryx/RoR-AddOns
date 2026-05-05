namespace WorldServer.Scripting.MoonSharp.Proxies;

using Common.Enums.GameData;
using Common.Enums.SystemData;
using global::MoonSharp.Interpreter;
using JetBrains.Annotations;
using World.Objects;

[PublicAPI]
public class PlayerProxy : UnitProxy
{
    private readonly Player _player;

    [MoonSharpHidden]
    public PlayerProxy(Player player)
        : base(player)
    {
        _player = player;
    }

    #region Money

    [PublicAPI]
    public uint Money => _player.GetMoney();

    [PublicAPI]
    public void AddMoney(uint money) => _player.AddMoney(money);

    [PublicAPI]
    public bool RemoveMoney(uint money) => _player.RemoveMoney(money);

    #endregion

    #region Items

    [PublicAPI]
    public bool AddItem(uint itemId, ushort count) => _player.Items.CreateItemNotify(itemId, count) == ItemResult.ResultOk;

    [PublicAPI]
    public bool RemoveItem(uint itemId, ushort count) => _player.Items.RemoveItems(itemId, count);

    [PublicAPI]
    public bool HasItem(uint itemId, ushort count) => _player.Items.HasItemCountInInventory(itemId, count);

    #endregion

    #region Chat

    [PublicAPI]
    public void SendLocalizeString(string message,  ChatLogFilters filter, LocalizedText localizeEntry) => _player.SendLocalizeString(message, (ChatLogFilter)filter, localizeEntry);

    #endregion

    #region World

    [PublicAPI]
    public void Teleport(ushort zoneId, uint x, uint y, ushort z, ushort o) => _player.Teleport(zoneId, x, y, z, o);

    #endregion

    #region Quest

    [PublicAPI]
    public bool TriggerQuestObjective(ushort questId, ushort questObjectiveId) => _player.Quests.TriggerQuestObjective(questId, questObjectiveId);

    #endregion

    #region ActionCounters

    [PublicAPI]
    public void IncrementActionCounter(ushort actionCounterId, uint value) => _player.ActionCounters.Increment(actionCounterId, value);

    #endregion
}
