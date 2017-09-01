using Uno.Compiler.ExportTargetInterop;

namespace Fuse.ConektaWrapper
{
    extern(!MOBILE)
    public class Core
    {
        static public void Init() { }
    }

    [extern(iOS) Require("Source.Include", "Conekta.h")]
    extern(iOS)
    public class Core
    {
	internal static string _publicKey = extern<string>"uString::Ansi(\"@(Project.Conekta.PublicKey:Or(''))\")";
	extern(iOS) internal static ObjC.Object _conekta;

        [Foreign(Language.ObjC)]
        static public void Init()
        @{
		Conekta *conekta = [[Conekta alloc] init];
		UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;

		[conekta setDelegate: controller];
		[conekta setPublicKey:@{Core._publicKey:Get()}];
		[conekta collectDevice];

		@{_conekta:Set(conekta)};
        @}
    }

    [Require("Gradle.Dependency.Compile", "io.conekta:conektasdk:2.1")]
    [ForeignInclude(Language.Java, "io.conekta.conektasdk.Conekta")]
    [ForeignInclude(Language.Java, "com.fuse.Activity")]
    extern(Android)
    public class Core
    {
        internal static string _publicKey = extern<string>"uString::Ansi(\"@(Project.Conekta.PublicKey:Or(''))\")";
        internal static string _apiVersion = extern<string>"uString::Ansi(\"@(Project.Conekta.ApiVersion:Or(''))\")";

        [Foreign(Language.Java)]
        static public void Init()
        @{
            Conekta.setPublicKey(@{Core._publicKey:Get()});
			if(!(@{Core._apiVersion:Get()}).isEmpty())
            	Conekta.setApiVersion(@{Core._apiVersion:Get()});
            Conekta.collectDevice(Activity.getRootActivity());
        @}
    }
}
