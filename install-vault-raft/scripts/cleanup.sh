#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# Quick Clean up - anything not managed by terraform
rm -rf ${DIR}/../tmp/tls
kubectl delete secrets vault-server-tls
kubectl delete csr vault-server-csr
kubectl delete secrets vault-agent-injector-tls
kubectl delete csr vault-agent-injector-csr
kubectl delete pvc data-vault-0 data-vault-1 data-vault-2 data-vault-3 data-vault-4
