#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ $(terraform output -state=${DIR}/../terraform.tfstate K8s_namespace) ]]; then
  ns=$(terraform output -state=${DIR}/../terraform.tfstate K8s_namespace)
else
  ns="default"
fi
echo "namespace: $ns"

SAN="vault-0 vault-1 vault-2 vault-3 vault-4 \
 vault-0.vault-internal.${ns}.svc.cluster.local \
 vault-1.vault-internal.${ns}.svc.cluster.local \
 vault-2.vault-internal.${ns}.svc.cluster.local \
 vault-3.vault-internal.${ns}.svc.cluster.local \
 vault-4.vault-internal.${ns}.svc.cluster.local \
 localhost 127.0.0.1 ::1"

if [[ ! $(which mkcert) ]]; then
  echo "This requires mkcert"
  exit
fi

if [[ ! -z $1 ]]; then
  tls_path="$1"
else
  tls_path="tmp/tls"
fi

if [[ ! -d $tls_path ]]; then
     mkdir -p  ${tls_path}
fi

export CAROOT="${tls_path}"
echo "Creating CA Root in: $CAROOT"
mkcert -install
mkcert -cert-file ${tls_path}/server.crt -key-file ${tls_path}/server.key ${SAN}
echo "Creating TLS Certs: ${tls_path}/server.crt, ${tls_path}/server.key"
