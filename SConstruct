#!/usr/bin/scons

from os.path import expanduser
from SCons.Script import Environment, ARGUMENTS, Variables, Touch, Copy, Delete, Mkdir, SConscript, PathVariable, BoolVariable, EnumVariable
import glob
import sys
import os

vars = Variables(None, ARGUMENTS)
vars.Add(PathVariable("TOOLING_PATH", "Toolchain bin dir", "/usr/bin", PathVariable.PathIsDir))
vars.Add(PathVariable("SDKROOT", "iOS SDK root", "/mnt/2tb/iOS/sdk8", PathVariable.PathIsDir))
vars.Add(BoolVariable("debug", "debug build", False))
vars.Add(EnumVariable("device", "install target", "default",
                      allowed_values=["default", "ios5", "ios6", "ios7"]))


env = Environment(Variables=vars)

if "TOOLING_PATH" not in vars.args:
    print(vars.GenerateHelpText(env))
    sys.exit(1)

homedir = expanduser("~")

env = Environment(
    variables=vars,
    AR="arm-apple-darwin9-ar",
    CC="arm-apple-darwin9-clang",
    CXX="arm-apple-darwin9-clang++",
    RANLIB="arm-apple-darwin9-ranlib",
    CFLAGS=[
        "-isysroot",
        "/mnt/2tb/iOS/sdk8",
        "-arch",
        "armv7",
        "-fblocks",
        "-fobjc-arc",
        "-Icurl",
        "-std=c11",
        "-Werror",
        "-Wno-deprecated-declarations",
    ],
    CPPFLAGS=[
        "-arch",
        "armv7",
        "-isysroot",
        "/mnt/2tb/iOS/sdk8",
        "-Werror",
    ],
    LINKFLAGS=[
        "-arch",
        "armv7",
        "-isysroot",
        "/mnt/2tb/iOS/sdk8",
        "-F/mnt/2tb/iOS/sdk8/System/Library/PrivateFrameworks",
    ],
    ENV={"PATH": vars.args["TOOLING_PATH"] + ":/usr/bin:/bin","LD_LIBRARY_PATH":"/nix/store/bfwqrbwqpbnsdbgf86gz8pn8vvddci3i-libxml2-2.13.8/lib"},
)
env.Help(vars.GenerateHelpText(env))
env.AppendENVPath("PATH", os.getenv("PATH"))
env.Clean(".", "xcbuild")

def disable_arc(env: Environment, srcs, src_file_name):
    try:
        idx = next(i for i, s in enumerate(srcs) if src_file_name in s)
    except StopIteration:
        print(f"File {src_file_name} not found in srcs")
        return
    srcs[idx] = env.SharedObject(srcs[idx], CFLAGS=env["CFLAGS"] + ["-fno-objc-arc"])

env.AddMethod(disable_arc)

# Arguments
debug = ARGUMENTS.get("debug", 0)
if int(debug):
    env.Append(CFLAGS=["-DDEBUG=1", "-g", "-O0"])
    env.Append(CPPFLAGS=["-DDEBUG=1", "-g", "-O0"])
else:
    env.Append(CFLAGS=["-O3", "-g"])
    env.Append(CPPFLAGS=["-O3", "-g"])
use_ios7 = ARGUMENTS.get("use_ios7", 0)
use_ios6 = ARGUMENTS.get("use_ios6", 1)
use_ios5 = ARGUMENTS.get("use_ios5", 0)

# Configs
VERSION = "2.1.2"
MAC_IP = "192.168.1.230"
IOS6_IP = "192.168.10.99"
IOS7_IP = "192.168.1.186"
IOS5_IP = "192.168.1.122"
if int(use_ios6):
    IPHONE_IP = IOS6_IP
elif int(use_ios7):
    IPHONE_IP = IOS7_IP
elif int(use_ios5):
    IPHONE_IP = IOS5_IP
else:
    IPHONE_IP = "192.168.1.189"

Export("env")

kscrash = SConscript("KSCrash/SConscript")
nanopb = SConscript("nanopb/SConscript")
env.Prepend(LIBS=[kscrash, nanopb])
veteris_prog = SConscript("Veteris/SConscript")

# Real file targets, not mismatched fantasy paths.
if debug:
    signed_prog = env.Command(
        "xcbuild/Veteris_.signed",
        veteris_prog,
        [
            Delete("$TARGET"),
            Copy("$TARGET", "$SOURCE"),
            "./ldid-2.1.5-amd64 -SVeteris/ent.xml $TARGET",
        ],
    )
else:
    signed_prog = env.Command(
        "xcbuild/Veteris_.signed",
        veteris_prog,
        [
            Delete("$TARGET"),
            Copy("$TARGET", "$SOURCE"),
            "./ldid-2.1.5-amd64 -SVeteris/ent.xml $TARGET",
        ],
    )
    stripped_prog = env.Command(
        "xcbuild/Veteris_.stripped",
        signed_prog,
        [
            Delete("$TARGET"),
            Copy("$TARGET", "$SOURCE"),
            "llvm-strip -s $TARGET",
        ],
    )

debug_symbols = env.Command(
    "xcbuild/Veteris_.dSYM",
    veteris_prog,
    "dsymutil $SOURCE -o $TARGET",
)

resources = [
    "Veteris/Images.xcassets",
    "Veteris/SVProgressHUD/SVProgressHUD.bundle",
    "Veteris/Settings.bundle",
    "Veteris/Veteris",
]
png_resources = glob.glob("Veteris/Images/*.png")
resources_preserve_path = [
    file
    for i in glob.glob("Veteris/*.lproj")
    for file in glob.glob(f"{i}/*.strings")
]

generated_settings = env.Substfile(
    "xcbuild/generated/Root.plist",
    "Veteris/Settings.bundle/Root.plist",
    SUBST_DICT={"%VERSION%": VERSION},
)

generated_info = env.Substfile(
    "xcbuild/generated/Info.plist",
    "Veteris/Veteris-Info.plist",
    SUBST_DICT={"%VERSION%": VERSION},
)

bundle_nodes = []
bundle_nodes += env.Install("xcbuild/Veteris.app", resources)
bundle_nodes += env.Install("xcbuild/Veteris.app", png_resources)
bundle_nodes += env.InstallAs("xcbuild/Veteris.app/Veteris_", signed_prog)
bundle_nodes += env.InstallAs("xcbuild/Veteris.app/Info.plist", generated_info)
bundle_nodes += env.InstallAs(
    "xcbuild/Veteris.app/Settings.bundle/Root.plist",
    generated_settings,
)

for source_path in resources_preserve_path:
    rel = source_path.replace("Veteris/", "", 1)
    bundle_nodes += env.InstallAs(f"xcbuild/Veteris.app/{rel}", source_path)

bundle_stamp = env.Command(
    "xcbuild/Veteris.app/.bundle_stamp",
    bundle_nodes,
    [
        "find xcbuild/Veteris.app -name '*.png' -print0 | xargs -0 -r ios-pngcrush -c",
        "find xcbuild/Veteris.app -name '*.plist' -print0 | xargs -0 -r ios-plutil -c",
        "find xcbuild/Veteris.app -name '*.strings' -print0 | xargs -0 -r ios-plutil -c",
        Touch("$TARGET"),
    ],
)

app = env.Alias("app", bundle_stamp)

ios_install = env.Alias(
    "ios-install",
    app,
    [
        f"sshpass -p alpine ssh -o PreferredAuthentications=password root@{IPHONE_IP} 'rm -fr /Applications/Veteris.app'",
        f"sshpass -p alpine scp -Or xcbuild/Veteris.app root@{IPHONE_IP}:/Applications/Veteris.app",
        f"sshpass -p alpine ssh -o PreferredAuthentications=password mobile@{IPHONE_IP} 'uicache'",
        f"sshpass -p alpine ssh -o PreferredAuthentications=password mobile@{IPHONE_IP} 'killall -9 Veteris_'",
    ],
)
env.AlwaysBuild(ios_install)

deb_pkg = env.Command(
    f"xcbuild/Veteris-v{VERSION}.deb",
    bundle_stamp,
    [
        Delete("xcbuild/Veteris-deb"),
        Mkdir("xcbuild/Veteris-deb/DEBIAN"),
        Mkdir("xcbuild/Veteris-deb/Applications"),
        "cp -r xcbuild/Veteris.app xcbuild/Veteris-deb/Applications/Veteris.app",
        "cp deb-stuff/control xcbuild/Veteris-deb/DEBIAN/control",
        f"echo Version: {VERSION} >> xcbuild/Veteris-deb/DEBIAN/control",
        "dpkg-deb -b -Zgzip --root-owner-group xcbuild/Veteris-deb $TARGET",
    ],
)
deb = env.Alias("deb", deb_pkg)

dist_nodes = [signed_prog, app]
if debug:
    dist_nodes.append(debug_symbols)
dist = env.Alias("dist", dist_nodes)

env.Clean(bundle_stamp, "xcbuild")
env.Default(dist)
