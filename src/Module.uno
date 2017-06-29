using Uno;
using Uno.UX;
using Uno.Threading;
using Fuse.Scripting;

namespace Fuse.Conekta
{
	/**
	*/
	[UXGlobalModule]
	public sealed class ConektaModule : NativeModule
	{
		static readonly ConektaModule _instance;

		public ConektaModule()
		{
			if(_instance != null) return;
			Uno.UX.Resource.SetGlobalKey(_instance = this, "Conekta");

			Core.Init();

			AddMember(new NativePromise<Scripting.Object, Scripting.Object>("createToken", TokenFromCard, TokenToJS));
		}

		Future<Scripting.Object> TokenFromCard(object[] args)
		{
			var card = (Scripting.Object)args[0];

			return new ConektaToken(card);
		}

		static Scripting.Object TokenToJS(Context c, Scripting.Object token)
		{
			return token;
		}
	}
}
