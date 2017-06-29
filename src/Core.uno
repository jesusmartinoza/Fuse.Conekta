using Uno.Compiler.ExportTargetInterop;

namespace Fuse.Conekta
{
    extern(!MOBILE || iOS)
    public class Core
    {
        static public void Init() { }
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
