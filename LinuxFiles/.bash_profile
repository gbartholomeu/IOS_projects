# ~/.bashrc
# .bash_profile

#Alias
alias ls='ls -GF' #-G para colorir o comando | -F mostra uma / após os arquivos que são diretórios |
alias cl='clear && clear && clear && clear' #Limpa a tela 4 vezes para "resetar" o console
alias ll='ls -lGF' #extra de -l para listar os arquivos
alias ic='ibmcloud'

#Functions
function getHostname(){
  local HOSTNAME_P=""
  if [ -n "$1" ];
  then
    HOSTNAME_P=$1
    local OCCURRENCES_P=$(grep -o "\." <<< "$HOSTNAME_P" | wc -l)

    if [ $OCCURRENCES_P  == 0 ];
    then
      HOSTNAME_P="$HOSTNAME_P.xxxx.xxxxxxxx"
    elif [ $OCCURRENCES_P == 1 ];
    then
      HOSTNAME_P="$HOSTNAME_P.xxxxxxxxx"
    fi
  fi
  
  echo "$HOSTNAME_P"
}


#Função sshc: utilizada para conectar nos domínios do carrefour com meu usuário
function sshc(){
  local HOSTNAME_P=$(getHostname $1)

  if [ -n "$HOSTNAME_P" ];
  then
      ssh $HOSTNAME_P -l xxxxxxxx
  else
     echo "Forneça um parâmetro por favor!"
  fi
}

#Função goiks: utilizada para inicializar e acessar o container docker rodando o IKS
function goiks(){
	local SITUACAO=$(docker ps | grep iks)
	
	if [ -z "$SITUACAO" ];
	then
		docker start xxxxxxx
	fi

	docker exec -it xxxxxxxx /bin/bash
}

#Função cpbash: utilizada para copiar meu arquivo .bash_profile customizado para o domínio Carrefour
function cpbash(){
	local DIR=$(pwd)
  local HOSTNAME_P=$(getHostname $1)

  cd ~

  if [ -n "$HOSTNAME_P" ];
  then  
    local TARGET_P="xxxxxxxx@$HOSTNAME_P:/home/xxxxxxxx/.bash_profile"
    scp Puppet.bash_profile $TARGET_P
  else
    echo "Não foi possível copiar o arquivo para o host."
  fi
  
  cd $DIR
}


#Função cpbash: utilizada para copiar meu arquivo .bash_profile customizado para o domínio Carrefour
function cpvim(){
  local DIR=$(pwd)
  local HOSTNAME_P=$(getHostname $1)

  cd ~

  if [ -n "$HOSTNAME_P" ];
  then
    local TARGET_P="xxxxxxxx@$HOSTNAME_P:/home/xxxxxxxx/.vimrc"
    scp .vimrc $TARGET_P
  else
    echo "Não foi possível copiar o arquivo para o host."
  fi
  
  cd $DIR
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

##Comando awk para remover a primeira linha do ls -l
#ls -lhtr | awk '{if(NR>1)print}'

##Type é utilizado para descrever algum tipo de arquivo, seja ele um alias, function, dir, etc.
#type

##Lista todos os serviços do ambiente
#systemctl list-unit-files
