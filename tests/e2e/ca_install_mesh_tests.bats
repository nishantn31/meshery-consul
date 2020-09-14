#load 'helpers'

setup() {
    KUBECTL_CONTEXT=$(kubectl config current-context)
    KUBECTL_CONFIG=$(kubectl config view | base64 -w 0 -)
    CREATE_MESH_REQ_MSG=$(cat <<EOT
{
  "k8sConfig": "$KUBECTL_CONFIG",
  "contextName": "$KUBECTL_CONTEXT"
}
EOT
)
}

@test "client instance should be created" {
  run bash -c "echo '$CREATE_MESH_REQ_MSG' | grpcurl --plaintext -d @ $MESHERY_ADAPTER_ADDR:10002 meshes.MeshService.CreateMeshInstance"
  [ "$status" -eq 0 ]
}

@test "consul_install should be successful" {
  INSTALL_CONSUL=$(cat <<EOT
{
  "opName": "consul_install",
  "namespace": "consul-e2e-tests",
  "username": "",
  "customBody": "",
  "deleteOp": false,
  "operationId": ""
}
EOT
)
  run bash -c "echo '$INSTALL_CONSUL' | grpcurl --plaintext -d @ $MESHERY_ADAPTER_ADDR:10002 meshes.MeshService.ApplyOperation"
  [ "$status" -eq 0 ]
}

@test "deployment/consul-consul-connect-injector-webhook-deployment should be ready" {
  run kubectl rollout status deployment/consul-consul-connect-injector-webhook-deployment -n consul-e2e-tests
  [ "$status" -eq 0 ]
}

@test "statefulset/consul-consul-server should be ready" {
  run kubectl rollout status statefulset/consul-consul-server -n consul-e2e-tests
  [ "$status" -eq 0 ]
}

@test "daemonset/consul-consul should be ready" {
  run kubectl rollout status daemonset/consul-consul -n consul-e2e-tests
  [ "$status" -eq 0 ]
}
