allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// receive_sharing_intent 1.9.0 hardcodes `compileSdk 37` in its own
// android/build.gradle. Google publishes only "platforms;android-37.0", and its
// metadata declares AndroidVersion.ApiLevel=37.0, which the SDK tooling parses
// as API level 0 — so AGP looks for hash string "android-37", finds nothing, and
// the build dies with "Failed to find target with hash string 'android-37'".
// Setting the app's own compileSdk does not help, because each plugin module
// resolves its own. Force every Android subproject onto the app's compileSdk
// until the plugins stop targeting 37.
//
// Reflection rather than the typed AGP extension: AGP's classes are not on the
// root buildscript classpath here, and this stays inert for non-Android modules.
subprojects {
    afterEvaluate {
        val androidExtension = extensions.findByName("android") ?: return@afterEvaluate
        val setCompileSdk = androidExtension.javaClass.methods.firstOrNull {
            it.name == "compileSdkVersion" &&
                it.parameterTypes.size == 1 &&
                it.parameterTypes[0] == Int::class.javaPrimitiveType
        }
        setCompileSdk?.invoke(androidExtension, 36)
    }
}

// Must stay after the block above: this forces evaluation, and afterEvaluate
// cannot be registered on an already-evaluated project.
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
