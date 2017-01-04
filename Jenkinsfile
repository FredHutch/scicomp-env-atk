#!/usr/bin/env groovy
node('knife-wks') {
    dir( 'src' ){
        stage 'Stage: Checkout'
        checkout scm
        
        stage 'Stage: Build'
        sh '''
          eval "$(chef shell-init sh)"
          env
          rake noop
        '''
    }
}
