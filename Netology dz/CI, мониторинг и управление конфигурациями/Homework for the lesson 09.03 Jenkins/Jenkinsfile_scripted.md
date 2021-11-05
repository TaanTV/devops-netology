````
node("ansible_docker"){
    stage("Git checkout"){
        git credentialsId: '11e80cd8-d7a2-4de1-90f7-3acc15b11eb2', url: 'https://github.com/TaanTV/example-playbook.git'
    }
    stage("Prepare ssh key"){
        sh 'ansible-vault decrypt secret --vault-password-file vault_pass'
        sh 'mkdir ~/.ssh/ && mv ./secret ~/.ssh/id_rsa && chmod 400 ~/.ssh/id_rsa'
    }
    stage("Install requirements"){
        sh 'ansible-galaxy install -r requirements.yml -p roles'
    }
    stage("Run playbook"){
        sh 'ansible-playbook site.yml -i inventory/prod.yml'
    }
}
```