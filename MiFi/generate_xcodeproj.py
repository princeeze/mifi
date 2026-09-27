#!/usr/bin/env python3
from pathlib import Path

counter = 0

def rid():
    global counter
    counter += 1
    return f"B{counter:023X}"

# Pre-assign IDs
ids = {k: rid() for k in [
    "proj", "main_group", "products_group", "shared_group", "app_group", "widget_group", "test_group",
    "core_target", "app_target", "widget_target", "test_target",
    "core_product", "app_product", "widget_product", "test_product",
    "core_sources", "app_sources", "widget_sources", "test_sources",
    "core_frameworks", "app_frameworks", "widget_frameworks", "test_frameworks",
    "core_headers", "app_resources", "embed_phase", "embed_build",
    "proj_config", "core_config_list", "app_config_list", "widget_config_list", "test_config_list",
    "debug", "release", "core_debug", "core_release", "app_debug", "app_release",
    "widget_debug", "widget_release", "test_debug", "test_release",
    "core_dep_app", "core_proxy_app", "core_dep_widget", "core_proxy_widget", "core_dep_test", "core_proxy_test",
    "widget_dep", "widget_proxy",
    "assets_ref", "assets_build", "app_ent_ref", "widget_ent_ref", "widget_plist_ref",
    "core_framework_build_app", "core_framework_build_widget", "core_framework_build_test",
    "embed_core_phase", "embed_core_build",
]}

files = {
    "core": [
        "Shared/MiFiCore.swift",
        "Shared/MiFiClient.swift",
        "Shared/CredentialsStore.swift",
        "Shared/AppGroupStore.swift",
        "Shared/UsageHistory.swift",
        "Shared/MiFiRefresh.swift",
        "Shared/ByteFormat.swift",
        "Shared/StatusView.swift",
        "Shared/RestartIntent.swift",
    ],
    "app": ["MiFiApp/MiFiApp.swift", "MiFiApp/HostView.swift"],
    "widget": ["MiFiWidget/MiFiWidget.swift", "MiFiWidget/MiFiWidgetBundle.swift"],
    "test": ["MiFiTests/UsageHistoryTests.swift"],
}

file_refs = {}
build_files = {}
for paths in files.values():
    for p in paths:
        file_refs[p] = rid()
        build_files[p] = rid()

lines = []
w = lines.append

w("// !$*UTF8*$!")
w("{")
w("\tarchiveVersion = 1;")
w("\tclasses = {};")
w("\tobjectVersion = 56;")
w("\tobjects = {")

for p, bf in build_files.items():
    name = Path(p).name
    w(f"\t\t{bf} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[p]} /* {name} */; }};")

w(f"\t\t{ids['assets_build']} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {ids['assets_ref']} /* Assets.xcassets */; }};")
w(f"\t\t{ids['embed_build']} /* MiFiWidgetExtension.appex in Embed Foundation Extensions */ = {{isa = PBXBuildFile; fileRef = {ids['widget_product']} /* MiFiWidgetExtension.appex */; settings = {{ATTRIBUTES = (RemoveHeadersOnCopy, ); }}; }};")
w(f"\t\t{ids['core_framework_build_app']} /* MiFiCore.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {ids['core_product']} /* MiFiCore.framework */; }};")
w(f"\t\t{ids['core_framework_build_widget']} /* MiFiCore.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {ids['core_product']} /* MiFiCore.framework */; }};")
w(f"\t\t{ids['core_framework_build_test']} /* MiFiCore.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {ids['core_product']} /* MiFiCore.framework */; }};")
w(f"\t\t{ids['embed_core_build']} /* MiFiCore.framework in Embed Frameworks */ = {{isa = PBXBuildFile; fileRef = {ids['core_product']} /* MiFiCore.framework */; settings = {{ATTRIBUTES = (CodeSignOnCopy, RemoveHeadersOnCopy, ); }}; }};")

for p, fr in file_refs.items():
    name = Path(p).name
    w(f"\t\t{fr} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = \"<group>\"; }};")

w(f"\t\t{ids['assets_ref']} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = \"<group>\"; }};")
w(f"\t\t{ids['app_ent_ref']} /* MiFiApp.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = MiFiApp.entitlements; sourceTree = \"<group>\"; }};")
w(f"\t\t{ids['widget_ent_ref']} /* MiFiWidget.entitlements */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = MiFiWidget.entitlements; sourceTree = \"<group>\"; }};")
w(f"\t\t{ids['widget_plist_ref']} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};")
w(f"\t\t{ids['core_product']} /* MiFiCore.framework */ = {{isa = PBXFileReference; explicitFileType = wrapper.framework; includeInIndex = 0; path = MiFiCore.framework; sourceTree = BUILT_PRODUCTS_DIR; }};")
w(f"\t\t{ids['app_product']} /* MiFi.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = MiFi.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
w(f"\t\t{ids['widget_product']} /* MiFiWidgetExtension.appex */ = {{isa = PBXFileReference; explicitFileType = \"wrapper.app-extension\"; includeInIndex = 0; path = MiFiWidgetExtension.appex; sourceTree = BUILT_PRODUCTS_DIR; }};")
w(f"\t\t{ids['test_product']} /* MiFiTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = MiFiTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};")

def frameworks_phase(phase_id, build_file_ids):
    w(f"\t\t{phase_id} /* Frameworks */ = {{")
    w("\t\t\tisa = PBXFrameworksBuildPhase;")
    w("\t\t\tbuildActionMask = 2147483647;")
    w("\t\t\tfiles = (")
    for bf in build_file_ids:
        w(f"\t\t\t\t{bf},")
    w("\t\t\t);")
    w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    w("\t\t};")

frameworks_phase(ids["core_frameworks"], [])
frameworks_phase(ids["app_frameworks"], [ids["core_framework_build_app"]])
frameworks_phase(ids["widget_frameworks"], [ids["core_framework_build_widget"]])
frameworks_phase(ids["test_frameworks"], [ids["core_framework_build_test"]])

def sources_phase(phase_id, paths):
    w(f"\t\t{phase_id} /* Sources */ = {{")
    w("\t\t\tisa = PBXSourcesBuildPhase;")
    w("\t\t\tbuildActionMask = 2147483647;")
    w("\t\t\tfiles = (")
    for p in paths:
        w(f"\t\t\t\t{build_files[p]} /* {Path(p).name} in Sources */,")
    w("\t\t\t);")
    w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
    w("\t\t};")

sources_phase(ids["core_sources"], files["core"])
sources_phase(ids["app_sources"], files["app"])
sources_phase(ids["widget_sources"], files["widget"])
sources_phase(ids["test_sources"], files["test"])

w(f"\t\t{ids['core_headers']} /* Headers */ = {{")
w("\t\t\tisa = PBXHeadersBuildPhase;")
w("\t\t\tbuildActionMask = 2147483647;")
w("\t\t\tfiles = (")
w("\t\t\t);")
w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w("\t\t};")

w(f"\t\t{ids['app_resources']} /* Resources */ = {{")
w("\t\t\tisa = PBXResourcesBuildPhase;")
w("\t\t\tbuildActionMask = 2147483647;")
w("\t\t\tfiles = (")
w(f"\t\t\t\t{ids['assets_build']} /* Assets.xcassets in Resources */,")
w("\t\t\t);")
w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w("\t\t};")

w(f"\t\t{ids['embed_core_phase']} /* Embed Frameworks */ = {{")
w("\t\t\tisa = PBXCopyFilesBuildPhase;")
w("\t\t\tbuildActionMask = 2147483647;")
w("\t\t\tdstPath = \"\";")
w("\t\t\tdstSubfolderSpec = 10;")
w("\t\t\tfiles = (")
w(f"\t\t\t\t{ids['embed_core_build']} /* MiFiCore.framework in Embed Frameworks */,")
w("\t\t\t);")
w("\t\t\tname = \"Embed Frameworks\";")
w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w("\t\t};")

w(f"\t\t{ids['embed_phase']} /* Embed Foundation Extensions */ = {{")
w("\t\t\tisa = PBXCopyFilesBuildPhase;")
w("\t\t\tbuildActionMask = 2147483647;")
w("\t\t\tdstPath = \"\";")
w("\t\t\tdstSubfolderSpec = 13;")
w("\t\t\tfiles = (")
w(f"\t\t\t\t{ids['embed_build']} /* MiFiWidgetExtension.appex in Embed Foundation Extensions */,")
w("\t\t\t);")
w("\t\t\tname = \"Embed Foundation Extensions\";")
w("\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w("\t\t};")

def group(gid, name, children, path=None):
    w(f"\t\t{gid} /* {name} */ = {{")
    w("\t\t\tisa = PBXGroup;")
    w("\t\t\tchildren = (")
    for c in children:
        w(f"\t\t\t\t{c},")
    w("\t\t\t);")
    if path:
        w(f"\t\t\tpath = {path};")
    w("\t\t\tsourceTree = \"<group>\";")
    w("\t\t};")

group(ids["shared_group"], "Shared", [file_refs[p] for p in files["core"]], "Shared")
group(ids["app_group"], "MiFiApp", [file_refs[p] for p in files["app"]] + [ids["assets_ref"], ids["app_ent_ref"]], "MiFiApp")
group(ids["widget_group"], "MiFiWidget", [file_refs[p] for p in files["widget"]] + [ids["widget_ent_ref"], ids["widget_plist_ref"]], "MiFiWidget")
group(ids["test_group"], "MiFiTests", [file_refs[p] for p in files["test"]], "MiFiTests")
group(ids["products_group"], "Products", [ids["core_product"], ids["app_product"], ids["widget_product"], ids["test_product"]])
group(ids["main_group"], "MiFi", [ids["shared_group"], ids["app_group"], ids["widget_group"], ids["test_group"], ids["products_group"]])

def target(tid, name, product, product_type, config_list, phases, deps, product_name):
    w(f"\t\t{tid} /* {name} */ = {{")
    w("\t\t\tisa = PBXNativeTarget;")
    w(f"\t\t\tbuildConfigurationList = {config_list};")
    w("\t\t\tbuildPhases = (")
    for p in phases:
        w(f"\t\t\t\t{p},")
    w("\t\t\t);")
    w("\t\t\tbuildRules = ();")
    w("\t\t\tdependencies = (")
    for d in deps:
        w(f"\t\t\t\t{d},")
    w("\t\t\t);")
    w(f"\t\t\tname = {name};")
    w(f"\t\t\tproductName = {product_name};")
    w(f"\t\t\tproductReference = {product} /* {Path(product_name).name if '.' in product_name else product_name} */;")
    w(f"\t\t\tproductType = \"{product_type}\";")
    w("\t\t};")

target(ids["core_target"], "MiFiCore", ids["core_product"], "com.apple.product-type.framework", ids["core_config_list"],
       [ids["core_headers"], ids["core_sources"], ids["core_frameworks"]], [], "MiFiCore")
target(ids["app_target"], "MiFi", ids["app_product"], "com.apple.product-type.application", ids["app_config_list"],
       [ids["app_sources"], ids["app_frameworks"], ids["app_resources"], ids["embed_core_phase"], ids["embed_phase"]],
       [ids["core_dep_app"], ids["widget_dep"]], "MiFi")
target(ids["widget_target"], "MiFiWidgetExtension", ids["widget_product"], "com.apple.product-type.app-extension", ids["widget_config_list"],
       [ids["widget_sources"], ids["widget_frameworks"]], [ids["core_dep_widget"]], "MiFiWidgetExtension")
target(ids["test_target"], "MiFiTests", ids["test_product"], "com.apple.product-type.bundle.unit-test", ids["test_config_list"],
       [ids["test_sources"], ids["test_frameworks"]], [ids["core_dep_test"]], "MiFiTests")

def dep(did, proxy, target):
    w(f"\t\t{proxy} /* PBXContainerItemProxy */ = {{")
    w("\t\t\tisa = PBXContainerItemProxy;")
    w(f"\t\t\tcontainerPortal = {ids['proj']} /* Project object */;")
    w("\t\t\tproxyType = 1;")
    w(f"\t\t\tremoteGlobalIDString = {target};")
    w(f"\t\t\tremoteInfo = MiFiCore;")
    w("\t\t};")
    w(f"\t\t{did} /* PBXTargetDependency */ = {{")
    w("\t\t\tisa = PBXTargetDependency;")
    w(f"\t\t\ttarget = {target} /* MiFiCore */;")
    w(f"\t\t\ttargetProxy = {proxy} /* PBXContainerItemProxy */;")
    w("\t\t};")

dep(ids["core_dep_app"], ids["core_proxy_app"], ids["core_target"])
dep(ids["core_dep_widget"], ids["core_proxy_widget"], ids["core_target"])
dep(ids["core_dep_test"], ids["core_proxy_test"], ids["core_target"])

w(f"\t\t{ids['widget_proxy']} /* PBXContainerItemProxy */ = {{")
w("\t\t\tisa = PBXContainerItemProxy;")
w(f"\t\t\tcontainerPortal = {ids['proj']} /* Project object */;")
w("\t\t\tproxyType = 1;")
w(f"\t\t\tremoteGlobalIDString = {ids['widget_target']};")
w("\t\t\tremoteInfo = MiFiWidgetExtension;")
w("\t\t};")
w(f"\t\t{ids['widget_dep']} /* PBXTargetDependency */ = {{")
w("\t\t\tisa = PBXTargetDependency;")
w(f"\t\t\ttarget = {ids['widget_target']} /* MiFiWidgetExtension */;")
w(f"\t\t\ttargetProxy = {ids['widget_proxy']} /* PBXContainerItemProxy */;")
w("\t\t};")

w(f"\t\t{ids['proj']} /* Project object */ = {{")
w("\t\t\tisa = PBXProject;")
w("\t\t\tattributes = {")
w("\t\t\t\tBuildIndependentTargetsInParallel = 1;")
w("\t\t\t\tLastSwiftUpdateCheck = 1600;")
w("\t\t\t\tLastUpgradeCheck = 1600;")
w("\t\t\t};")
w(f"\t\t\tbuildConfigurationList = {ids['proj_config']};")
w("\t\t\tcompatibilityVersion = \"Xcode 14.0\";")
w("\t\t\tdevelopmentRegion = en;")
w("\t\t\thasScannedForEncodings = 0;")
w("\t\t\tknownRegions = (en, Base);")
w(f"\t\t\tmainGroup = {ids['main_group']};")
w(f"\t\t\tproductRefGroup = {ids['products_group']};")
w("\t\t\tprojectDirPath = \"\";")
w("\t\t\tprojectRoot = \"\";")
w("\t\t\ttargets = (")
for t in [ids["core_target"], ids["app_target"], ids["widget_target"], ids["test_target"]]:
    w(f"\t\t\t\t{t},")
w("\t\t\t);")
w("\t\t};")

def build_settings(name, bundle, is_framework=False, is_test=False, entitlements=None, info_plist=None):
    s = {
        "MACOSX_DEPLOYMENT_TARGET": "15.0",
        "SWIFT_VERSION": "5.0",
        "PRODUCT_NAME": "$(TARGET_NAME)",
        "PRODUCT_BUNDLE_IDENTIFIER": bundle,
        "CODE_SIGN_STYLE": "Automatic",
        "CURRENT_PROJECT_VERSION": "1",
        "MARKETING_VERSION": "1.0",
        "ENABLE_HARDENED_RUNTIME": "YES",
    }
    if is_framework:
        s.update({
            "DEFINES_MODULE": "YES",
            "DYLIB_INSTALL_NAME_BASE": "@rpath",
            "INSTALL_PATH": "$(LOCAL_LIBRARY_DIR)/Frameworks",
            "SKIP_INSTALL": "YES",
            "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/../Frameworks @loader_path/Frameworks",
        })
    elif is_test:
        s.update({
            "BUNDLE_LOADER": "$(TEST_HOST)",
            "TEST_HOST": "$(BUILT_PRODUCTS_DIR)/MiFi.app/Contents/MacOS/MiFi",
            "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/../Frameworks @loader_path/../Frameworks",
        })
    else:
        runpaths = "$(inherited) @executable_path/../Frameworks"
        if bundle.endswith("MiFiWidget"):
            runpaths += " @executable_path/../../Frameworks"
        s.update({
            "LD_RUNPATH_SEARCH_PATHS": runpaths,
        })
    if entitlements and not is_test:
        s["INFOPLIST_KEY_NSLocalNetworkUsageDescription"] = "Connect to your MiFi on the local network for status and usage."
    if entitlements:
        s["CODE_SIGN_ENTITLEMENTS"] = entitlements
    if info_plist:
        s["INFOPLIST_FILE"] = info_plist
        s["GENERATE_INFOPLIST_FILE"] = "NO"
    else:
        s["GENERATE_INFOPLIST_FILE"] = "YES"
    return s

def config(cid, name, settings):
    w(f"\t\t{cid} /* {name} */ = {{")
    w("\t\t\tisa = XCBuildConfiguration;")
    w("\t\t\tbuildSettings = {")
    for k, v in settings.items():
        if isinstance(v, str):
            w(f"\t\t\t\t{k} = {v};")
        else:
            w(f"\t\t\t\t{k} = {v};")
    w("\t\t\t};")
    w(f"\t\t\tname = {name};")
    w("\t\t};")

base_debug = {
    "ALWAYS_SEARCH_USER_PATHS": "NO",
    "CLANG_ENABLE_MODULES": "YES",
    "COPY_PHASE_STRIP": "NO",
    "DEBUG_INFORMATION_FORMAT": "dwarf",
    "GCC_DYNAMIC_NO_PIC": "NO",
    "GCC_OPTIMIZATION_LEVEL": "0",
    "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE",
    "ONLY_ACTIVE_ARCH": "YES",
    "SDKROOT": "macosx",
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG",
    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
}
base_release = dict(base_debug)
base_release.update({"GCC_OPTIMIZATION_LEVEL": "s", "SWIFT_OPTIMIZATION_LEVEL": "-O", "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym", "MTL_ENABLE_DEBUG_INFO": "NO", "ONLY_ACTIVE_ARCH": "NO"})
base_release.pop("SWIFT_ACTIVE_COMPILATION_CONDITIONS", None)

config(ids["debug"], "Debug", base_debug)
config(ids["release"], "Release", base_release)

for pair, bundle, extra in [
    (("core_debug", "core_release"), "com.mifi.MiFiCore", {"framework": True}),
    (("app_debug", "app_release"), "com.mifi.MiFiApp", {"ent": "MiFiApp/MiFiApp.entitlements"}),
    (("widget_debug", "widget_release"), "com.mifi.MiFiApp.MiFiWidget", {"ent": "MiFiWidget/MiFiWidget.entitlements", "plist": "MiFiWidget/Info.plist"}),
    (("test_debug", "test_release"), "com.mifi.MiFiTests", {"test": True}),
]:
    for cfg_name, cid in zip(("Debug", "Release"), pair):
        s = build_settings("", bundle, is_framework=extra.get("framework"), is_test=extra.get("test"),
                           entitlements=extra.get("ent"), info_plist=extra.get("plist"))
        s.update(base_debug if cfg_name == "Debug" else {k: v for k, v in base_release.items()})
        config(cid, cfg_name, s)

def config_list(clid, cfgs):
    w(f"\t\t{clid} /* Build configuration list */ = {{")
    w("\t\t\tisa = XCConfigurationList;")
    w("\t\t\tbuildConfigurations = (")
    for c in cfgs:
        w(f"\t\t\t\t{c},")
    w("\t\t\t);")
    w("\t\t\tdefaultConfigurationIsVisible = 0;")
    w("\t\t\tdefaultConfigurationName = Release;")
    w("\t\t};")

config_list(ids["proj_config"], [ids["debug"], ids["release"]])
config_list(ids["core_config_list"], [ids["core_debug"], ids["core_release"]])
config_list(ids["app_config_list"], [ids["app_debug"], ids["app_release"]])
config_list(ids["widget_config_list"], [ids["widget_debug"], ids["widget_release"]])
config_list(ids["test_config_list"], [ids["test_debug"], ids["test_release"]])

w("\t};")
w(f"\trootObject = {ids['proj']} /* Project object */;")
w("}")

out = Path("/Users/admin/Workspace/mifi/MiFi/MiFi.xcodeproj/project.pbxproj")
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text("\n".join(lines) + "\n")
print(f"Wrote {out}")
