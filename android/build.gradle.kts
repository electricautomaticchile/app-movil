// FCM / Firebase:
// Este proyecto usa el DSL moderno de plugins. La versión del plugin de Google
// Services se declara en android/settings.gradle.kts:
//     id("com.google.gms.google-services") version "4.4.2" apply false
// y se aplica en android/app/build.gradle.kts. No hace falta 'buildscript { classpath ... }'.
// El repositorio google() de abajo ya provee los artefactos de Firebase/Google Services.
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
