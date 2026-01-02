allprojects {
    repositories {
        google()
        mavenCentral()
        
        // 阿里云镜像 (注意：Kotlin 语法必须由 url = uri("...") 这样写)
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/jcenter") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
    }
}

// 这里的写法也针对 Kotlin 进行了调整
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    project.layout.buildDirectory.value(rootProject.layout.buildDirectory.dir(project.name))
}
subprojects {
    // Kotlin 中必须用双引号表示字符串
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
