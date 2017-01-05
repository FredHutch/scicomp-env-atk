#!/usr/bin/env groovy
node('knife-wks') {
    dir( 'src' ){
        checkout scm
        stage 'Stage: SCM Checkout'
        checkout scm
        stage 'Stage: Smoke Tests'
        sh '''
        eval "$(chef shell-init sh)"
        rake test
        '''
        stage 'Stage: Integration Testing'
        echo 'Starting Test Kitchen'
        sh '''
        eval "$(chef shell-init sh)"
        kitchen verify
        '''
        stage 'Stage: Upload Check'
        // Upload cookbook to supermarket if:
        //    - it is on the production branch
        //    - it has a new version (i.e. DNE in
        //      market or server)
        sh '''
            eval "$(chef shell-init sh)"
            rake build
        '''
    }
}
