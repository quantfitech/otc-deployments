#!/usr/bin/env fish


for chart in (fd Chart.yaml . -x echo {//})
  echo "checking '$chart'"
  helm template ./$chart | kubeconform -output tap -summary \
    -kubernetes-version="master" \
    -schema-location default \
    -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' \
    -schema-location 'https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/{{.NormalizedKubernetesVersion}}/{{.ResourceKind}}.json' \
    -schema-location 'https://json.schemastore.org/{{.ResourceKind}}.json'
end
