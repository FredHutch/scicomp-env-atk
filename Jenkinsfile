#!/usr/bin/env groovy
node('knife-wks') {
    dir( 'src' ){
        stage 'Stage: Checkout'
        checkout scm
        
        stage 'Stage: Build'
        sh '''
          eval "$(chef shell-init sh)"
          echo "branch to build is ${env.BRANCH_NAME}"
          rake noop
        '''
    }
}
