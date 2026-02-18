#!/bin/bash

# Verifica se está rodando como root
if [ "$EUID" -ne 0 ]; then
  echo "Execute como root: sudo ./setup_tpm.sh"
  exit 1
fi

echo "Atualizando sistema..."
apt update && apt upgrade -y

echo "Instalando tpm2-tools..."
apt install -y tpm2-tools

echo "Limpando TPM..."
tpm2_clear

echo "Criando primary key (sha256)..."
tpm2_createprimary -C e -g sha256 -G rsa -c primary_sha256.ctx

echo "Exportando chave pública..."
tpm2_readpublic -c primary_sha256.ctx -f pem -o endorsement_pub.pem

echo "Criando primary key (sha1)..."
tpm2_createprimary -C e -g sha1 -G rsa -c primary_sha1.ctx

echo "Criando novamente primary key (sha1)..."
tpm2_createprimary -C e -g sha1 -G rsa -c primary_sha1_2.ctx

echo "Fixando chave no handle persistente..."
tpm2_evictcontrol -C o -c primary_sha1_2.ctx 0x81010001

echo "Processo finalizado com sucesso!"
