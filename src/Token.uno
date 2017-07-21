using Uno;
using Uno.Compiler.ExportTargetInterop;
using Uno.Threading;
using Fuse.Scripting;

namespace Fuse.ConektaWrapper
{
	extern(!MOBILE) class ConektaToken : Promise<string>
	{
		public ConektaToken(Scripting.Object card)
		{
			Reject(new Exception("Couldn't create token. Platform not supported"));
		}
	}

	[extern(iOS) Require("Source.Include", "Conekta.h")]
	extern(iOS) class ConektaToken : Promise<string>
	{
		//internal static string _publicKey = extern<string>"uString::Ansi(\"@(Project.Conekta.PublicKey:Or(''))\")";

		public ConektaToken(Scripting.Object card)
		{
			if(card["name"] == null)
				Reject(new Exception("'name' not found in JSON"));
			if(card["number"] == null)
				Reject(new Exception("'number' not found in JSON"));
			if(card["cvc"] == null)
				Reject(new Exception("'cvc' not found in JSON"));
			if(card["month"] == null)
				Reject(new Exception("'month' not found in JSON"));
			if(card["year"] == null)
				Reject(new Exception("'year' not found in JSON"));

			CreateToken(card["name"] as string, card["number"] as string, card["cvc"] as string, card["month"] as string, card["year"] as string);
		}

		[Foreign(Language.ObjC)]
		public extern(iOS) void CreateToken(String name, String number, String cvc, String month, String year)
		@{
			Conekta *conekta = @{Core._conekta:Get()};

			Card *card = [conekta.Card initWithNumber: number name: name cvc: cvc expMonth: month expYear: year];

			Token *token = [conekta.Token initWithCard:card];

			[token createWithSuccess: ^(NSDictionary *data) {
				@{ConektaToken:Of(_this).Reject(string):Call([data objectForKey:@"id"])};
			} andError: ^(NSError *error) {
				@{ConektaToken:Of(_this).Reject(string):Call(error.localizedDescription)};
			}];
		@}

		void Resolve(string token)
		{
			Resolve(token);
		}

		void Reject(string reason)
		{
			Reject(new Exception(reason));
		}
	}

	[ForeignInclude(Language.Java,
		"io.conekta.conektasdk.Conekta",
		"io.conekta.conektasdk.Token",
		"io.conekta.conektasdk.Card",
		"org.json.JSONObject",
		"com.fuse.Activity",
		"android.util.Log")]
	extern(Android) class ConektaToken : Promise<string>
	{
		public ConektaToken(Scripting.Object card)
		{
			if(card["name"] == null)
				Reject(new Exception("'name' not found in JSON"));
			if(card["number"] == null)
				Reject(new Exception("'number' not found in JSON"));
			if(card["cvc"] == null)
				Reject(new Exception("'cvc' not found in JSON"));
			if(card["month"] == null)
				Reject(new Exception("'month' not found in JSON"));
			if(card["year"] == null)
				Reject(new Exception("'year' not found in JSON"));

			CreateToken(card["name"] as string, card["number"] as string, card["cvc"] as string, card["month"] as string, card["year"] as string);
		}

		[Foreign(Language.Java)]
		public extern(Android) void CreateToken(String name, String number, String cvc, String month, String year)
		@{
			Token token = new Token(Activity.getRootActivity());
			Card card = new Card(name, number, cvc, month, year);

			//Listen when token is returned
			token.onCreateTokenListener(new Token.CreateToken() {
				@Override
				public void onCreateTokenReady(JSONObject data) {
					String uuid = Conekta.deviceFingerPrint(Activity.getRootActivity());
					try {
						if(data.getString("object").equals("error"))
							@{ConektaToken:Of(_this).Reject(string):Call(data.getString("message"))};
						else
							@{ConektaToken:Of(_this).Resolve(string):Call(data.getString("id"))};
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
			Resolve(token);
		}

		void Reject(string reason)
		{
			Reject(new Exception(reason));
		}
	}
}
