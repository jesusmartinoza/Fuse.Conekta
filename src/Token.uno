using Uno;
using Uno.Compiler.ExportTargetInterop;
using Uno.Threading;
using Fuse.Scripting;

namespace Fuse.Conekta
{
    extern(!MOBILE || iOS) class ConektaToken : Promise<Scripting.Object>
	{
        public ConektaToken(Scripting.Object card)
        {
            Reject("Couldn't create token");
        }
	}

	[ForeignInclude(Language.Java,
					"io.conekta.conektasdk.Conekta",
					"io.conekta.conektasdk.Token",
					"io.conekta.conektasdk.Card",
					"org.json.JSONObject",
                    "com.fuse.Activity")]
    extern(Android) class ConektaToken : Promise<Scripting.Object>
    {
		public string id = "conekta_token";

		public Scripting.Object card;

        public ConektaToken(Scripting.Object card)
        {
            this.card = card;
            CreateToken(card["name"] as string, card["number"] as string, card["cvc"] as string, card["month"] as string, card["year"] as string);
        }

        [Foreign(Language.Java)]
        public static extern(Android) void CreateToken(String name, String number, String cvc, String month, String year)
        @{
            Token token = new Token(Activity.getRootActivity());
            Card card = new Card(name, number, cvc, month, year);

            //Listen when token is returned
            token.onCreateTokenListener(new Token.CreateToken() {
                @Override
                public void onCreateTokenReady(JSONObject data) {
                    String uuid = Conekta.deviceFingerPrint(Activity.getRootActivity());
                    try {
                        String id = data.getString("id");
                        @{ConektaToken:Of(_this).Resolve(string):Call(id)};
                    } catch (Exception err) {
                        @{ConektaToken:Of(_this).Reject(string):Call(err.toString())};
                    }
                }
            });

            //Request for create token
            token.create(card);
        @}

		void Resolve(string token)
		{
            var obj = new object() as Scripting.Object;
            obj["token"] = token;
			Resolve(obj);
		}

		void Reject(string reason)
		{
			Reject(new Exception(reason));
		}
    }
}
