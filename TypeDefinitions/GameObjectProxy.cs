namespace WorldServer.Scripting.MoonSharp.Proxies;

using global::MoonSharp.Interpreter;
using JetBrains.Annotations;
using World.Objects;

[PublicAPI]
public class GameObjectProxy : UnitProxy
{
    private readonly GameObject _gameObject;

    [MoonSharpHidden]
    public GameObjectProxy(GameObject gameObject)
        : base(gameObject)
    {
        _gameObject = gameObject;
    }

    [PublicAPI]
    public uint Entry => _gameObject.Entry;

    [PublicAPI]
    public bool Interactable => _gameObject.Interactable;

    [PublicAPI]
    public void SetState(string stateName, int state) => _gameObject.ScriptState.SetState(stateName, state);

    [PublicAPI]
    public int? GetState(string stateName) => _gameObject.ScriptState.GetState(stateName);

    [PublicAPI]
    public byte VfxState { get => _gameObject.VfxState; set => _gameObject.VfxState = value; }

    [PublicAPI]
    public bool NoRespawn { get => _gameObject.NoRespawn; set => _gameObject.NoRespawn = value; }
}
