pipeline{
    agent(docker)
    scm checkout
    stages{
        stage(build){
            steps{
                dir(./backend){
                    sh '''
                    docker build -t 
                    '''
                }
            }
        }
    }

}