#!groovy

node {
    properties([
        parameters([
            gitTagVersionInput()
        ])
    ])
    
    runDefaultDockerPipeline currentBuild: currentBuild, imageName: "timoreymann/chrooted-ftp"
}
