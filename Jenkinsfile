#!/usr/bin/env groovy
def runme
node('knife-wks') {
    dir( 'src' ){
        checkout scm
        sh '''
          eval "$(chef shell-init bash)"
          rake noop
        '''
    }
}
