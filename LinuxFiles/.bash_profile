# ~/.bashr
# .bash_profile

#Alias
alias ls='ls -GF' #-G para colorir o comando | -F mostra uma / após os arquivos que são diretórios |
alias cl='clear && clear && clear && clear' #Limpa a tela 4 vezes para "resetar" o console
alias ll='ls -l' #extra de -l para listar os arquivos

function getHostname(){
  local HOSTNAME_P=""
  if [ -n "$1" ];
  then
    HOSTNAME_P=$1
    local OCCURRENCES_P=$(grep -o "\." <<< "$HOSTNAME_P" | wc -l)

    if [ $OCCURRENCES_P  == 0 ];
    then
      HOSTNAME_P="$HOSTNAME_P.xxx.xxx"
    elif [ $OCCURRENCES_P == 1 ];
    then
      HOSTNAME_P="$HOSTNAME_P.xxx"
    fi
  fi
  
  echo "$HOSTNAME_P"
}


#Função sshc: utilizada para conectar nos domínios do carrefour com meu usuário
function sshc(){
  local HOSTNAME_P=$(getHostname $1)

  if [ -n "$HOSTNAME_P" ];
  then
      ssh $HOSTNAME_P -l myUser
  else
     echo "Forneça um parâmetro por favor!"
  fi
}

#Função godocker: utilizada para inicializar e acessar o container docker rodando o IKS
function godocker(){
	local SITUACAO=$(docker ps | grep iks)
	
	if [ -z "$SITUACAO" ];
	then
		docker start $CONTAINER_NAME
	fi

	docker exec -it $CONTAINER_NAME /bin/bash
}

#Função cpbash: utilizada para copiar meu arquivo .bash_profile customizado para o domínio Carrefour
function cpbash(){
  local HOSTNAME_P=$(getHostname $1)

  if [ -n "$HOSTNAME_P" ];
  then  
    local TARGET_P="myUser@$HOSTNAME_P:/home/myUser/.bash_profile"
    scp ~/Puppet.bash_profile $TARGET_P
  else
    echo "Não foi possível copiar o arquivo para o host."
  fi
}

#Função cpvim: utilizada para copiar meu arquivo .bash_profile customizado para o domínio Carrefour
function cpvim(){
  local HOSTNAME_P=$(getHostname $1)

  if [ -n "$HOSTNAME_P" ];
  then
    local TARGET_P="myUser@$HOSTNAME_P:/home/myUser/.vimrc"
    scp ~/.vimrc $TARGET_P
  else
    echo "Não foi possível copiar o arquivo para o host."
  fi
}

#Função hist: History + opção de grep
function hist(){
	if [ -z "$1" ];
  then
    history
  else
    history | grep $1
  fi
}
#Função psg: Função criada para mostrar os processos em execução. Se utilizado com um parâmetro, realizará um grep.
function psg() {
  if [ -z "$1" ];
  then
    ps aux
  else
    ps aux | grep $1
  fi
}

#Function podsall: Função desenvolvida para listar os posd em modo wide em 3 cenários. 
#Cenário 1 - Sem parâmetros informados: Ao utilizar a função sem parâmetros, o sistema listará todos os pods
#Cenário 2 - Apenas um parâmetro informado: Ao utilizar a função com apenas um parâmetro, o sistema perguntará se deseja realizar uma busca pelo namespace ou por um grep
#Cenário 3 - Dois parâmetros: Ao utilizar dois parâmetros, o sistema primeiro realizará uma busca por namespace e depois um grep em cima dos pods do namespace.
function podsall() {
  if [ -z "$1" ] && [ -z "$2" ];
  then
    kubectl get pods --all-namespaces -o wide
  elif [ -n "$1" ] && [ -z "$2" ];
  then
    PS3=":"
    options=("namespace" "grep" )
        select opt in "${options[@]}"; do
    case $opt in
    "namespace")
      kubectl get pods --namespace $1 -o wide; break
    ;;
    "grep")
      kubectl get pods --all-namespaces -o wide | grep $1; break
    ;;
    *) echo "invalid option $REPLY";;
    esac
    done
  else
    kubectl get pods --namespace $1 -o wide | grep $2
  fi
}

#Function delpod: Função desenvolvida para apagar um pod usando diretamente o nome dele sem precisar ficar obtendo ou digitando o namespace do mesmo.
function delpod(){
  if [ -n "$1" ];
  then 
    local NAMESPACE_P=$(kubectl get pods --all-namespaces | grep $1 | awk '{ print $1}')

    if [ -n "$NAMESPACE_P" ];
    then
      kubectl delete pod --namespace $NAMESPACE_P $1
    else
      echo "Namespace $1 nao localizado."
    fi
  else
    echo "Por favor forneca um parametro!" 
  fi
}

#Function sdu: Função desenvolvida para listar os diretórios com maior consumo de disco. Caso receba 1 ou mais parâmetro, realizará o --exclude de cada um deles.
function sdu() {
  local DIRS_P=$@
  local EXCLUDE_OPTS=" "

  if [ -z "$DIRS_P" ];
  then
    sudo du -sh --time * | sort -h
  else
    DIRS_ARRAY=( "$@")
    for elem in "${DIRS_ARRAY[@]}";
    do
      EXCLUDE_OPTS=(${EXCLUDE_OPTS[@]} --exclude="$elem" )
    done
    sudo du -sh --time * "${EXCLUDE_OPTS[@]}" | sort -h
  fi
}

#Comandos genéricos salvos
##Exibir dois comandos lado a lado:
# paste <(comando1) <(comando2) | column -s $'\t' -t

##Lista os pacotes instalados | Apenas Linux
#rpm -qa

##Grep "básico": -r busca recursiva | -i Ignora case sensitive | -H printa o header do arquivo com o resultado | -e Regex | -I ignora binários | -l Lista apenas o nome do arquivo
#grep ./* -riHI -e "qualquer texto"

##Grep excluindo diretórios da busca
#grep ./ -irIH -e "qualquerCoisa" --exclude-dir=diretorio <-Excluir diretório de busca do grep

##Find básico para procurar o arquivo pelo nome. Pode ser utilizado -type para filtrar o tipo de arquivo, -newer para buscar mais novos que x arquivo|data e -not -newer para arquivos mais velhos que x arquivo|data
#find ./* -name "*smb*"

##Find com formatação para mostrar a data de modificação do arquivo.
#find ./ -printf "%p %TY-%Tm-%Td \n" <- Comando para exibir o dia do arquivo no comando do find

##Executando o rm após um find.
#find ./ -type f -newer /tmp/begin -not -newer /tmp/end -exec rm -rf '{}' \;

##Comando awk para remover a primeira linha do ls -l
#ls -lhtr | awk '{if(NR>1)print}'

##Type é utilizado para descrever algum tipo de arquivo, seja ele um alias, function, dir, etc.
#type

##Lista todos os serviços do ambiente
#systemctl list-unit-files

##Kubernetes pod scaling
#kubectl get deployment,statefulset,replicaset -n $POD_NAMESPACE
#kubectl scale replicaset --replicas=0 -n $POD_NAMESPACE $REPLICA_ID
#kubectl scale deployment --replicas=0 -n $POD_NAMESPACE $DEPLOYMENT_ID

#Verificando memória (RAM)
#ps -o pid,user,%mem,command ax | sort -b -k3 -r

##Verificando os servicos do Kubernetes:
#kubectl get svc --all-namespaces

##Verificando arquivos presos no sistema:
#lsof +L1 /backup -> Verificar qual sintaxe que substituirá o /backup

##Comando para baixar e subir os serviços do Idera que travam o disco na /backup das máquinas Oracle
#ps -ef | grep cdp
#/etc/init.d/cdp-agent status
#/etc/init.d/cdp-agent stop
#/etc/init.d/cdp-agent start
